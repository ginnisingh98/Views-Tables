--------------------------------------------------------
--  DDL for Package IGS_DA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDA09S.pls 115.1 2003/04/11 08:09:59 smanglm noship $ */

/*********************************************************************************************************
 Created By         : Jitendra Handa
 Date Created By    : 28-Mar-2003
 Purpose            : This package is defined for procedures that are to be used from the Self Service
		      pages.  All procedures and functions used by the Self Service will be defined here.
 remarks            : None
 Change History

Who             When           What
-----------------------------------------------------------
Jitendra    28-Mar-2003    New Package created.
***************************************************************************************************************/

PROCEDURE release_report_to_students (
    p_batch_id IN NUMBER
);

PROCEDURE create_req_stdnts_rec (p_batch_id                          IN NUMBER,
                                 X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
                                 X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
                                 X_MSG_COUNT                         OUT NOCOPY    NUMBER
                                ) ;

END IGS_DA_UTILS_PKG;

 

/
