--------------------------------------------------------
--  DDL for Package IGS_UC_MV_DATA_UPLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_MV_DATA_UPLD" AUTHID CURRENT_USER AS
/* $Header: IGSUC31S.pls 115.1 2002/11/29 04:22:16 nsidana noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGS_UC_MV_DATA_UPLD                     |
 |                                                                       |
 | NOTES                                                                 |
 |     This is a Concurrent requeset set which segregates the data into  |
 |     dummy hercules table after checking and validating the data.      |
 |     This also rearranges the data in the record data spans more than  |
 |     one record.                                                       |
 |                                                                       |
 | HISTORY                                                               |
 | Who             When            What                                  |
 *=======================================================================*/


  FUNCTION get_check_digit(
                           p_appno  VARCHAR2
                           ) RETURN NUMBER;

  PROCEDURE process_marvin_data(
                                ERRBUF      OUT NOCOPY  VARCHAR2,
                                RETCODE     OUT NOCOPY  NUMBER
                               );

END igs_uc_mv_data_upld;

 

/
