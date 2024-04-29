--------------------------------------------------------
--  DDL for Package XXAH_MGT_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_MGT_REP_PKG" AS

PROCEDURE project_reporting
(
    x_retbuf            OUT   VARCHAR2
  , x_retcode           OUT   NUMBER
);

PROCEDURE negotiation_reporting
(
    x_retbuf            OUT   VARCHAR2
  , x_retcode           OUT   NUMBER
)
;

END xxah_mgt_rep_pkg;
 

/
