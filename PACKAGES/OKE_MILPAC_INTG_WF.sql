--------------------------------------------------------
--  DDL for Package OKE_MILPAC_INTG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_MILPAC_INTG_WF" AUTHID CURRENT_USER AS
/* $Header: OKEMIRVS.pls 115.4 2002/11/19 20:35:05 jxtang noship $ */

PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);


PROCEDURE Create_Attachment
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
);

END OKE_MILPAC_INTG_WF;

 

/
