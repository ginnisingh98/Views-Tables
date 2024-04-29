--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_005" AS
/* $Header: IGSAD83B.pls 115.80 2003/12/09 12:54:26 pbondugu ship $ */
/*************************************
|| Change History
||  who           when        what
|| npalanis       17-FEB-2002 2758854 - New interface table race is created under person statistics
||                            source category therefore delete procedure for statistics source category is
||                            modified.
|| rrengara       14-feb-2003 for rct build , replaced the new table names with RCT table names. also added logic
||                            for inquiry lines table
||  gmuralid      4 -DEC-2002       Change by gmuralid, removed reference to table igs_ad_intl_int,
||                                  igs_pe_fund_dep_int.Included references to igs_pe_visa_int,
||                                  igs_pe_vst_hist_int,igs_pe_passport_int,igs_pe_eit_int
||                                  As a part of BUG 2599109, SEVIS Build
||
||  npalanis    15-feb-2002  Bug ID -2225917 :SWCR008 Cursor  C1 and  its references are removed . p_acct_site_uses_rec variable is removed
||                           Calls HZ_CUSTOMER_ACCOUNTS.CREATE_ACCT_SITE_USES and  HZ_CUSTOMER_ACCOUNTS.UPDATE_ACCT_SITE_USES
||                           are removed  .In  prc_pe_addr  check for getting cust_acct_id is removed
||                           In call to IGS_AD_IMP_002.create_address cust_account_id is not passed
||  ssawhney   9-may-2002    Bug 2338473 -- allow for more than one HZ error to appear, where ever direct calls to HZ APIs are present.
||  ssawhney   21-may-2002   Bug 2381539, PRC_PE_ADDR incorrect join between interface_addr_id and interface_id removed.
||			     to get the person information for whom the address is being created.
||  npalanis    16-JUN-2002  Bug -2327077
||                           In the prc_pe_addr procedure the interface records with only status '1' and '4' are picked
||                           for processing.
||  ssawhney    24-oct-2002  SWS104 build ACAD_HONORS moved to PE_ACAD_HONORS, PERSON_ACAD_HONORS category.
||  sjalasut    Oct 31,02    SWSCR012, Person Interests Migration Build. Removed ref of college act
||                           and changed category of Extra Curr ACT to PERSON_ACTIVITIES
|| pbondugu  Obsoleted the package as part of Import Process Enhancements
*/


END Igs_Ad_Imp_005;

/
