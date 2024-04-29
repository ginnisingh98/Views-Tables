--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FDF" AS
/* $Header: IGSFI27B.pls 115.4 2002/08/30 11:21:09 smvk ship $ */

/*
Who         When            What
smvk        30-Aug-2002     Obsoleted this entire package,both spec and body,
                            as a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
vchappid    02-May-2002     Bug 2329407, function finp_val_ftci_acc_cd has been changed to return FALSE always since the Account_cd
                            column in the table igs_fi_f_typ_ca_inst has been obsoleted in the SFCR05 Obsolete Items CCR, but the
                            code is still existing which is refering account_cd column.
*/
END IGS_FI_VAL_FDF;

/
