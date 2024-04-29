--------------------------------------------------------
--  DDL for Package XXAH_CONTRACT_CONV_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_CONTRACT_CONV_UPDATE_PKG" AS

 /* ************************************************************************
  * Copyright (c)  2010    Oracle Netherlands             De Meern
  * All rights reserved
  **************************************************************************
  *
  * FILENAME           : XXAH_CONTRACT_CONV_UPDATE_PKG.pks
  * AITHOR             : Kevin Bouwmeester, Oracle NL Appstech
  * DESCRIPTION        : Package specification with logic for the update of the
  *                      franchise contract conversion.
  * LAST UPDATE DATE   : 29-APR-2010
  *
  * HISTORY
  * =======
  *
  * VER  DATE         AUTHOR(S)          DESCRIPTION
  * ---  -----------  -----------------  -----------------------------------
  * 1.0  16-DEC-2009  Kevin Bouwmeester  Genesis
  *************************************************************************/

  PROCEDURE update_conversion
  ( errbuf               OUT VARCHAR2
  , retcode              OUT NUMBER
  );

END XXAH_CONTRACT_CONV_UPDATE_PKG;
 

/
