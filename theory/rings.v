Set Automatic Introduction.

Require Import
  Ring.
Require Import
  Program Morphisms
  abstract_algebra.

Section group_props. Context `{Group}.

  Lemma inv_involutive x: - - x == x.
  Proof.
   rewrite <- (monoid_lunit x) at 2.
   rewrite <- (inv_l (- x)).
   rewrite <- associativity.
   rewrite inv_l.
   rewrite monoid_runit.
   reflexivity.
  Qed.

  Global Instance: Injective group_inv.
  Proof. intros x y E. rewrite <- (inv_involutive x), <- (inv_involutive y), E. reflexivity. Qed.

  Lemma inv_zero: - mon_unit == mon_unit.
  Proof. rewrite <- (inv_l mon_unit) at 3. rewrite monoid_runit. reflexivity. Qed.

End group_props.

Lemma sg_inv_distr `{AbGroup} x y: - (x & y) == - x & - y.
Proof.
 rewrite <- (monoid_lunit (- x & - y)).
 rewrite <- (inv_l (x & y)).
 rewrite <- associativity.
 rewrite <- associativity.
 rewrite (commutativity (- x) (- y)).
 rewrite (associativity y).
 rewrite inv_r.
 rewrite monoid_lunit.
 rewrite inv_r.
 rewrite monoid_runit.
 reflexivity.
Qed.

Section semiring_props. Context `{SemiRing R}.

  Lemma plus_0_r x: x + 0 == x. Proof. intros. apply (monoid_runit x). Qed.
  Lemma plus_0_l x: 0 + x == x. Proof. intros. apply (monoid_lunit x). Qed.
  Lemma mult_1_l: forall a, 1 * a == a. Proof. intros. apply (monoid_lunit a). Qed.
  Lemma mult_1_r: forall a, a * 1 == a. Proof. intros. apply (monoid_runit a). Qed.

  Lemma mult_0_r (x: R): x * 0 == 0.
  Proof. rewrite commutativity. apply mult_0_l. Qed.

  Lemma stdlib_semiring_theory: Ring_theory.semi_ring_theory 0 1 ring_plus ring_mult equiv.
  Proof with try reflexivity.
   constructor; intros.
          apply plus_0_l.
         apply commutativity.
        apply associativity.
       apply mult_1_l.
      apply mult_0_l.
     apply commutativity.
    apply associativity.
   apply distribute_r.
  Qed.

End semiring_props.

Implicit Arguments stdlib_semiring_theory [[e] [plus0] [mult0] [zero] [one] [H]].

Section semiringmor_props. Context `{SemiRing_Morphism}.

  Existing Instance a_sg.
  Lemma preserves_0: f 0 == 0.
  Proof. intros. apply (@preserves_mon_unit _ _ _ _ _ _ _ _ f _). Qed.
  Lemma preserves_1: f 1 == 1.
  Proof. intros. apply (@preserves_mon_unit _ _ _ _ _ _ _ _ f _). Qed.
  Lemma preserves_mult: forall x y, f (x * y) == f x * f y.
  Proof. intros. apply preserves_sg_op. Qed.
  Lemma preserves_plus: forall x y, f (x + y) == f x + f y.
  Proof. intros. apply preserves_sg_op. Qed.

End semiringmor_props.

Section ring_props. Context `{Ring R}.

  Lemma plus_opp_r x: x + -x == 0. Proof. intros. apply (inv_r x). Qed.
  Lemma plus_opp_l x: -x + x == 0. Proof. intros. apply (inv_l x). Qed.

  Lemma plus_mul_distribute_r x y z: (x + y) * z == x * z + y * z. Proof. apply distribute_r. Qed.
  Lemma plus_mul_distribute_l x y z: x * (y + z) == x * y + x * z. Proof. apply distribute_l. Qed.

  Lemma twice a (h: a == a + a): a == 0. (* todo: doesn't this hold for semirings? *)
   rewrite <- (plus_opp_r a).
   rewrite h at 2.
   rewrite <- associativity.
   rewrite plus_opp_r.
   rewrite (monoid_runit a).
   reflexivity.
  Qed.

  Global Instance Ring_Semi: SemiRing R := { mult_0_l := _ }.
  Proof. intros. apply twice. rewrite <- distribute_r. rewrite (monoid_lunit 0). reflexivity. Qed.

  Lemma stdlib_ring_theory: Ring_theory.ring_theory 0 1 ring_plus ring_mult (fun x y => x + - y) group_inv equiv.
  Proof.
   constructor; intros.
           apply plus_0_l.
          apply commutativity.
         apply associativity.
        apply mult_1_l.
       apply commutativity.
      apply associativity.
     apply distribute_r.
    reflexivity.
   apply plus_opp_r.
  Qed.

  Add Ring R: stdlib_ring_theory.

  Lemma opp_swap x y: x + - y == - (y + - x).
  Proof. ring. Qed.

  Lemma plus_opp_distr x y: - (x + y) == - x + - y.
  Proof. apply sg_inv_distr. Qed.

  Lemma ring_plus_left_inj a a' b: a + b == a' + b -> a == a'.
  Proof.
   intro E.
   rewrite <- (plus_0_r a), <- (plus_0_r a').
   rewrite <- (plus_opp_r b).
   do 2 rewrite associativity.
   rewrite E. reflexivity.
  Qed.

  Lemma ring_opp_mult a: -a == -(1) * a.
  Proof.
   apply ring_plus_left_inj with a.
   rewrite <- (mult_1_l a) at 4.
   rewrite <- distribute_r.
   do 2 rewrite plus_opp_l.
   symmetry. apply mult_0_l.
  Qed.

  Lemma ring_distr_opp_mult a b: -(a * b) == -a * b.
  Proof. rewrite ring_opp_mult, (ring_opp_mult a). apply associativity. Qed.

  Lemma ring_opp_mult_opp a b: -a * -b == a * b.
  Proof.
   rewrite <- ring_distr_opp_mult.
   rewrite commutativity.
   rewrite <- ring_distr_opp_mult.
   rewrite commutativity.
   apply inv_involutive.
  Qed.

  Lemma opp_0: -0 == 0. Proof. apply (@inv_zero R _ _ _ _ _). Qed.

  Lemma ring_distr_opp a b: -(a+b) == -a+-b.
  Proof. ring. Qed. (* hm, probably not worth a lemma then *)

  Lemma equal_by_zero_sum x y: x + - y == 0 -> x == y.
  Proof. intro E. rewrite <- (plus_0_l y). rewrite <- E. ring. Qed.

  Lemma plus_reg_l n m p: p + n == p + m -> n == m.
  Proof.
   intro E.
   rewrite <- plus_0_l.
   rewrite <- (plus_opp_l p).
   rewrite <- associativity.
   rewrite E.
   ring.
  Qed.

End ring_props.

Implicit Arguments stdlib_ring_theory [[e] [plus0] [mult0] [inv] [zero] [one] [H]].

Section ringmor_props. Context `{Ring_Morphism A B f}.

  Lemma preserves_opp x: f (- x) == - f x.
  Proof. intros. apply preserves_inv. Qed.

  Global Instance Ring_Semi_Morphism: SemiRing_Morphism f.
  Proof. destruct H. constructor; apply _. Qed.

End ringmor_props.

Section morphism_composition.

  Context (A B C: Type)
    `{!RingMult A} `{!RingPlus A} `{!RingOne A} `{!RingZero A} `{!Equiv A}
    `{!RingMult B} `{!RingPlus B} `{!RingOne B} `{!RingZero B} `{!Equiv B}
    `{!RingMult C} `{!RingPlus C} `{!RingOne C} `{!RingZero C} `{!Equiv C}
    (f: A -> B) (g: B -> C).

  Global Instance id_semiring_morphism `{!SemiRing A}: SemiRing_Morphism id.
  Proof. repeat (constructor; try apply _); reflexivity. Qed.

  Global Instance compose_semiring_morphisms
    `{!SemiRing_Morphism f} `{!SemiRing_Morphism g}: SemiRing_Morphism (fun x => g (f x)).
  Proof with try reflexivity.
   pose proof (semiringmor_a).
   pose proof (semiringmor_b).
   pose proof (semiringmor_b: SemiRing C).
   assert (Proper (equiv ==> equiv) (fun x: A => g (f x))). intros x y E. rewrite E...
   repeat (constructor; try apply _); intros.
      do 2 rewrite preserves_sg_op...
     do 2 rewrite preserves_0...
    do 2 rewrite preserves_sg_op...
   do 2 rewrite preserves_1...
  Qed.

  Context `{!GroupInv A} `{!GroupInv B} `{!GroupInv C}.

  Global Instance id_ring_morphism `{!Ring A}: Ring_Morphism id.
  Proof. repeat (constructor; try apply _); reflexivity. Qed.

  Global Instance compose_ring_morphisms
    `{!Ring_Morphism f} `{!Ring_Morphism g}: Ring_Morphism (fun x => g (f x)).
  Proof.
   pose proof (ringmor_a).
   pose proof (ringmor_b).
   pose proof (ringmor_b: Ring C).
   repeat (constructor; try apply _).
   intros. do 2 rewrite preserves_inv. reflexivity.
  Qed.

End morphism_composition.