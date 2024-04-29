--------------------------------------------------------
--  DDL for Package PERWSEPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PERWSEPY_PKG" AUTHID CURRENT_USER AS
/* $Header: pepyppkg.pkh 120.1.12000000.1 2007/01/22 02:24:03 appldev noship $ */

  PROCEDURE CHECK_LENGTH(p_amount        IN OUT NOCOPY NUMBER
                        ,p_uom           IN     VARCHAR2
                        ,p_currcode      IN     VARCHAR2);

  PROCEDURE CALCULATE_PERCENTS_P (p_change_amount IN OUT NOCOPY NUMBER,
                                  p_change_percent IN OUT NOCOPY NUMBER,
                                  p_old_amount IN NUMBER,
                                  p_new_amount IN OUT NOCOPY NUMBER,
                                  p_multi_components IN OUT NOCOPY VARCHAR2,
                                  p_components VARCHAR2);

  PROCEDURE COMPONENT_AMOUNT_P (p_change_amount IN OUT NOCOPY NUMBER
                               ,p_old_amount    IN     NUMBER
                               ,p_uom           IN     VARCHAR2
                               ,p_currcode      IN     VARCHAR2
                               ,p_change_percent   OUT NOCOPY NUMBER);

  PROCEDURE COMPONENT_PERCENT_P  (p_change_percent IN OUT NOCOPY NUMBER
                                 ,p_old_amount     IN     NUMBER
                                 ,p_change_amount     OUT NOCOPY NUMBER
                                 ,p_status         IN     VARCHAR2
                                 ,p_uom            IN     VARCHAR2
                                 ,p_currcode       IN     VARCHAR2);


---------------------------------------------------------------------------------
/* Following procedure has been copied from per_pyp_bus.
   Some of the restrictions has been commented in per_pyp_bus as enhancement in FPKRUP.
   This need to be restriced for the old Salary Form.
   Change made by abhshriv
*/

  procedure chk_assignment_id_change_date
  (p_pay_proposal_id            in      per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id          in      per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id		in 	per_pay_proposals.assignment_id%TYPE
  ,p_change_date		in	per_pay_proposals.change_date%TYPE
  ,p_payroll_warning	 out nocopy     boolean
  ,p_object_version_number	in	per_pay_proposals.object_version_number%TYPE
  );

  procedure chk_del_pay_proposal
  (p_pay_proposal_id		in     per_pay_proposals.pay_proposal_id%TYPE
  ,p_object_version_number      in     per_pay_proposals.object_version_number%TYPE
  ,p_salary_warning        out nocopy boolean
  );

   procedure chk_delete_component
   (p_component_id
   in	  per_pay_proposal_components.component_id%TYPE
   );

  procedure  chk_pay_basis_change_date
              (p_assignment_id  in  per_pay_proposals.assignment_id%TYPE
              ,p_change_date    in  per_pay_proposals.change_date%TYPE
  );
----------------------------------------------------------------------------------


  PROCEDURE PROPOSED_SALARY_P (p_pay_proposal_id       IN     NUMBER
                              ,p_business_group_id     IN     NUMBER
                              ,p_assignment_id         IN     NUMBER
                              ,p_change_date           IN     DATE
                              ,p_proposed_salary       IN OUT NOCOPY NUMBER
                              ,p_object_version_number IN     NUMBER
                              ,p_old_amount            IN     NUMBER
                              ,p_uom                   IN     VARCHAR2
                              ,p_currcode              IN     VARCHAR2
                              ,p_components            IN OUT NOCOPY VARCHAR2
                              ,p_change_amount            OUT NOCOPY NUMBER
                              ,p_change_percent           OUT NOCOPY NUMBER);

  PROCEDURE CHANGE_AMOUNT_P (p_change_amount IN OUT NOCOPY NUMBER
                            ,p_old_amount    IN     NUMBER
                            ,p_components    IN OUT NOCOPY VARCHAR2
                            ,p_uom           IN     VARCHAR2
                            ,p_currcode      IN     VARCHAR2
                            ,p_new_amount       OUT NOCOPY NUMBER
                            ,p_change_percent   OUT NOCOPY NUMBER);

  PROCEDURE CHANGE_PERCENT_P (p_change_percent IN OUT NOCOPY NUMBER
                             ,p_old_amount     IN     NUMBER
                             ,p_components     IN OUT NOCOPY VARCHAR2
                             ,p_uom            IN     VARCHAR2
                             ,p_currcode       IN     VARCHAR2
                             ,p_new_amount        OUT NOCOPY NUMBER
                             ,p_change_amount     OUT NOCOPY NUMBER);

  PROCEDURE CHANGE_DATE_P    (p_pay_proposal_id IN NUMBER
                             ,p_business_group_id IN NUMBER
                             ,p_assignment_id IN NUMBER
                             ,p_change_date IN DATE
                             ,p_next_sal_review_date IN OUT NOCOPY DATE
                             ,p_object_version_number IN NUMBER
                             ,p_payroll_warning OUT NOCOPY BOOLEAN
                             ,p_inv_next_sal_date_warning OUT NOCOPY BOOLEAN);

  PROCEDURE NEXT_SAL_REVIEW_DATE_P(p_pay_proposal_id NUMBER
                                  ,p_business_group_id NUMBER
                                  ,p_assignment_id NUMBER
                                  ,p_change_date DATE
                                  ,p_next_sal_review_date IN OUT NOCOPY DATE
                                  ,p_object_version_number NUMBER
                                  ,p_inv_next_sal_date_warning OUT NOCOPY BOOLEAN);

  PROCEDURE APPROVED_P(p_pay_proposal_id       IN     NUMBER
                      ,p_business_group_id     IN     NUMBER
                      ,p_assignment_id         IN     NUMBER
                      ,p_change_date           IN     DATE
                      ,p_proposed_salary       IN     NUMBER
                      ,p_object_version_number IN     NUMBER
                      ,p_approved              IN     VARCHAR2);

  PROCEDURE COMPONENT_APPROVED_P(p_component_id IN     NUMBER
                      ,p_approved              IN     VARCHAR2
                      ,p_component_reason      IN     VARCHAR2
                      ,p_change_amount         IN     NUMBER
                      ,p_change_percentage     IN     NUMBER
                      ,p_object_version_number IN     NUMBER);

  PROCEDURE check_for_unaproved(p_assignment_id     NUMBER
                               ,l_error         OUT NOCOPY BOOLEAN);

  PROCEDURE CHECK_START_END_ASS_DATES(p_date          IN     DATE
                                     ,p_assignment_id IN     NUMBER
                                     ,p_start_ass_date_err OUT NOCOPY BOOLEAN
                                     ,p_end_ass_date_err   OUT NOCOPY BOOLEAN);


END PERWSEPY_PKG;

 

/
