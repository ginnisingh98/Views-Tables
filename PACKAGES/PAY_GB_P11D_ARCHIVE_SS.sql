--------------------------------------------------------
--  DDL for Package PAY_GB_P11D_ARCHIVE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P11D_ARCHIVE_SS" AUTHID CURRENT_USER AS
/* $Header: pygbpdss.pkh 120.0.12010000.2 2009/10/13 12:56:09 krreddy ship $ */
   PROCEDURE archinit (
      p_payroll_action_id   IN   NUMBER
   );
   PROCEDURE range_cursor (
      pactid   IN       NUMBER,
      sqlstr   OUT   NOCOPY     VARCHAR2
   );
   PROCEDURE action_creation (
      pactid      IN   NUMBER,
      stperson    IN   NUMBER,
      endperson   IN   NUMBER,
      chunk       IN   NUMBER
   );
   PROCEDURE archive_code (
      p_assactid         IN   NUMBER,
      p_effective_date   IN   DATE
   );
   PROCEDURE deinitialization_code (
      pactid   IN   NUMBER
   );

   Function is_p11d_benefit_allowed
   (p_effective_date date,
    p_person_id Number
    )
    return number;

   PROCEDURE get_parameters(
    p_payroll_action_id IN NUMBER,
    p_token_name IN VARCHAR2,
    p_token_value OUT NOCOPY VARCHAR2);

    g_updated_flag         VARCHAR2(1);

END;

/
