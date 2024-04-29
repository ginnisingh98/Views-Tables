--------------------------------------------------------
--  DDL for Package IGS_FI_MERGE_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_MERGE_CUST" AUTHID CURRENT_USER AS
/* $Header: IGSFI73S.pls 120.1 2005/09/08 14:22:59 appldev noship $ */
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  19-Feb-2002
  Purpose        :  This package is used for merging the Customer Account, Site and Site Usage
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

***********************************************************************************************/
  PROCEDURE merge(REQ_ID          IN  NUMBER,
                  SET_NUMBER      IN  NUMBER,
                  PROCESS_MODE    IN  VARCHAR2);
END igs_fi_merge_cust;

 

/
