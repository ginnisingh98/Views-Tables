--------------------------------------------------------
--  DDL for Package Body IGS_FI_MERGE_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_MERGE_CUST" AS
/* $Header: IGSFI73B.pls 120.1 2005/09/08 15:28:52 appldev noship $ */
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  19-Feb-2002
  Purpose        :  This package is used for merging the Customer Account, Site and Site Usage
  Known limitations,enhancements,remarks:
  Change History
  Who      When        What
  shtatiko 28-MAY-2003 Enh# 2831582, Obsoleted procedure merge.
  vvutukur 16-Jan-2003 Bug#2447534.Modifications done in procedure merge.
  agairola 28-May-2002 For bug 2391262, modified the procedure merge
********************************************************************************************** */

PROCEDURE merge (
        req_id                       NUMBER,
        set_number                   NUMBER,
        process_mode                 VARCHAR2) IS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  19-Feb-2002
  Purpose        :  This procedure is called by the AR procedure
                    for merging the Customer Account, Site and Site Usage
  Known limitations,enhancements,remarks:
  Change History
  Who      When        What
  shtatiko 28-MAY-2003 Enh# 2831582, Obsoleted this procedure.
  vvutukur 16-Jan-2003 Bug#2447534.Modifications done as per two newly added TCA enchacements for customer account merge
                       1. Auditing during account merge 2. ability to merge across operating units.
  agairola 28-May-2002 For bug 2391262, modified the token from TABLE to TABLE_NAME
********************************************************************************************** */

BEGIN

  -- Enh# 2831582, Obsoleting this procedure. But this procedure is not removed from Package Spec
  -- because this procedure is called from AR.
  NULL;

END merge;

END igs_fi_merge_cust;

/
