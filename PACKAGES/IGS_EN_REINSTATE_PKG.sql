--------------------------------------------------------
--  DDL for Package IGS_EN_REINSTATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_REINSTATE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSENB4S.pls 120.0 2005/09/13 22:16:50 appldev noship $ */
/*--------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA         |
 |                            All rights reserved.                                |
 +================================================================================+
 |                                                                                |
 | DESCRIPTION                                                                    |
 |      PL/SQL spec for package: IGS_EN_REINSTATE_PKG                                |
 |                                                                                |
 | NOTES                                                                          |
 |                                                                                |
 |                                                                                |
 | HISTORY                                                                        |
 | Who         When           What                                                */


  PROCEDURE reinstate_stdnt_unit_attempt(
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_person_type                  IN     VARCHAR2,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_message                      OUT NOCOPY VARCHAR2,
    p_deny_warn                    OUT NOCOPY VARCHAR2
  ) ;

END IGS_EN_REINSTATE_PKG;

 

/
