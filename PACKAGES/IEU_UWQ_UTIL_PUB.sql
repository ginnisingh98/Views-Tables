--------------------------------------------------------
--  DDL for Package IEU_UWQ_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: IEUUTILS.pls 120.1 2005/06/23 13:47:49 appldev ship $ */

function to_number_noerr(str VARCHAR2) RETURN NUMBER;

PROCEDURE DETERMINE_SOURCE_APP
  (P_RESP_ID         IN  NUMBER
  ,P_CLASSIFICATION  IN  VARCHAR2
  ,P_MEDIA_TYPE_UUID IN  VARCHAR2
  ,X_APP_ID          OUT NOCOPY NUMBER);

end IEU_UWQ_UTIL_PUB;

 

/
