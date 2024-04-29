--------------------------------------------------------
--  DDL for Package IGS_PS_PURGE_DEL_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_PURGE_DEL_RECORD" AUTHID CURRENT_USER AS
/* $Header: IGSPS88S.pls 120.1 2005/10/04 00:31:19 appldev ship $ */
/***********************************************************************************************

  Created By     :  shtatiko
  Date Created By:  19-FEB-2003
  Purpose        :  To purge logically deleted records from the tables, where logical delete
                    functionality is being used. This package is specific for Program Structure
                    and Planning module only i.e., this will process only tables of PSP module.

  Known limitations,enhancements,remarks:
  Change History
  Who 	     When          What

***********************************************************************************************/

PROCEDURE purge_ps_records ;

END igs_ps_purge_del_record;

 

/
