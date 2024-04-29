--------------------------------------------------------
--  DDL for Package ASO_APR_RESOURCE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_RESOURCE_HANDLER" AUTHID CURRENT_USER AS
  /*  $Header: asoiarhs.pls 120.1 2005/06/29 12:32:25 appldev ship $ */
  PROCEDURE getfirstapprover (
    approvaltypeidin            IN       INTEGER,
    parametersin                IN       VARCHAR2,
                                        /* parametersIn not used, in this case */
    sourceruleidlistin          IN       VARCHAR2,
    firstapproverout            OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );

  PROCEDURE getnextapprover (
    approvaltypeidin            IN       INTEGER,
    approverin                  IN       VARCHAR2,
    parametersin                IN       VARCHAR2,
    sourceruleidlistin          IN       VARCHAR2,
    nextapproverout             OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );

  PROCEDURE getsurrogate (
    approverin                  IN       VARCHAR2,
    parametersin                IN       VARCHAR2,
    surrogateout                OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );

  PROCEDURE hasfinalauthority (
    approverin                  IN       VARCHAR2,
    parametersin                IN       VARCHAR2,
    hasfinalauthorityynout      OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );

  PROCEDURE isasubordinate (
    subordinatein               IN       VARCHAR2,
    supervisorin                IN       VARCHAR2,
    isasubordinateynout         OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );
END aso_apr_resource_handler;

 

/
