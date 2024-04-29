--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_028
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_028" AUTHID CURRENT_USER AS
/* $Header: IGSADC8S.pls 115.3 2003/12/09 13:32:35 pbondugu noship $ */

/*************************************
|| Change History
||  who           when		  what
||  pbondugu   22-APR-2003  Admissions Legacy Import to import person legacy data
*/

PROCEDURE prc_pe_qual_details (
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2)  ;


CURSOR c_uc_qual_cur  (p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE) IS
              --Selects qualification details interface records which are in status on '2'
          SELECT
            rowid, ucint.*
          FROM
            Igs_uc_qual_ints ucint
          WHERE
           ucint.interface_run_id = p_interface_run_id
          AND ucint.status = '2'
          ORDER BY ucint.person_id;






END IGS_AD_IMP_028;

 

/
