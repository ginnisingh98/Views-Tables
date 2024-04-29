--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_BALANCES" AUTHID CURRENT_USER AS
/* $Header: IGSFI57S.pls 120.0 2005/06/01 14:30:31 appldev noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 27052001
  --
  --Purpose: Package  specification contains definition of procedures
  --         calc_balances and calculate_balances
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pathipat    08-OCT-2002     Enh# 2562745  Added new procedures convert_holds_balances() and
  --                            conv_balances() for new concurrent program, Holds Conversion.
  --vvutukur    04-Oct-2002     Enh#2562745.Added new parametre p_balance_rule_id to the generic function
  --                            check_exclusion_rules,removed existing calculate_balance procedure and
  --                            existing calculate_balance_1 local function in package body is renamed
  --                            as a public procedure calculate_balance.
  --smvk        17-Sep-2002     Removed the parameter p_subaccount_id from the procedures calc_balances,
  --                            calculate_balance and update_balances. As a part of Enh Bug # 2564643.
  --Nishikant   14DEC2001	A new parameter source_id is added in the procedure
  --                            update_balances for enhancement bug#2124001
  --Nishikant   10DEC2001       The function check_exclusion_rules added for the
  --                            enhancement bug# 2124001
  --sykrishn    03october2001   Added a new proc update_balances according to SFCR10
  --
  -------------------------------------------------------------------

  PROCEDURE calc_balances ( errbuf           OUT NOCOPY VARCHAR2                             ,
                            retcode          OUT NOCOPY NUMBER                               ,
                            p_person_id      IN  igs_pe_person_v.person_id%TYPE       ,
                            p_person_id_grp  IN  igs_pe_persid_group_v.group_id%TYPE  ,
                           /* Removed the parameter p_subaccount_id as a part of Bug # 2564643 */
                            p_bal_type       IN  igs_lookups_view.lookup_code%TYPE    ,
                            p_bal_date       IN  VARCHAR2                             ,
                            p_org_id         IN  NUMBER
                          ) ;
 PROCEDURE calculate_balance(p_person_id            IN  igs_pe_person_v.person_id%TYPE,
                             p_balance_type         IN  igs_lookup_values.lookup_code%TYPE,
                             p_balance_date         IN  igs_fi_balances.balance_date%TYPE,
			     p_action               IN  VARCHAR2,
			     p_balance_rule_id      IN  igs_fi_balance_rules.balance_rule_id%TYPE,
			     p_balance_amount       OUT NOCOPY igs_fi_balances.standard_balance%TYPE,
                             p_message_name         OUT NOCOPY fnd_new_messages.message_name%TYPE
                            );

 PROCEDURE update_balances (    p_party_id       IN  igs_fi_balances.party_id%TYPE       ,
                              /* Removed the parameter p_subaccount_id as a part of Bug # 2564643 */
                                p_balance_type   IN  igs_lookups_view.lookup_code%TYPE    ,
                                p_balance_date   IN  igs_fi_balances.balance_date%TYPE    ,
                                p_amount         IN  igs_fi_inv_int.invoice_amount%TYPE ,
                                p_source         IN  VARCHAR2 ,
                                p_source_id      IN  NUMBER DEFAULT NULL,
                                p_message_name   OUT NOCOPY fnd_new_messages.message_name%TYPE
                              ) ;
FUNCTION check_exclusion_rules (
   	                   p_balance_type	IN      igs_fi_balance_rules.balance_name%TYPE ,
	                   p_balance_date	IN      igs_fi_balance_rules.effective_start_date%TYPE,
	                   p_source_type        IN      VARCHAR2 ,
	                   p_source_id          IN      NUMBER   ,
			   p_balance_rule_id    IN      igs_fi_balance_rules.balance_rule_id%TYPE,
	                   p_message_name       OUT NOCOPY     VARCHAR2 ) RETURN BOOLEAN;

PROCEDURE convert_holds_balances( p_conv_st_date IN igs_fi_balance_rules.last_conversion_date%TYPE );

PROCEDURE conv_balances ( errbuf          OUT NOCOPY    VARCHAR2,
                          retcode         OUT NOCOPY	 NUMBER,
			  p_conv_st_date  IN     VARCHAR2 );

END IGS_FI_PRC_BALANCES ;

 

/
