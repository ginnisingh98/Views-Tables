--------------------------------------------------------
--  DDL for Package HZ_DUP_EXCLUSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_EXCLUSIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQDES.pls 120.1 2005/06/16 21:10:33 jhuang noship $*/
PROCEDURE Insert_Row(
                      px_DUP_EXCLUSION_ID           IN OUT   NOCOPY NUMBER,
	              p_PARTY_ID                          NUMBER,
                      p_DUP_PARTY_ID                      NUMBER,
                      p_FROM_DATE                         DATE,
                      p_TO_DATE                           DATE,
 	              p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Lock_Row(
                      p_DUP_EXCLUSION_ID      IN OUT   NOCOPY NUMBER,
	              p_PARTY_ID                          NUMBER,
                      p_DUP_PARTY_ID                      NUMBER,
                      p_FROM_DATE                         DATE,
                      p_TO_DATE                           DATE,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Update_Row(
                      p_DUP_EXCLUSION_ID            NUMBER,
                      p_PARTY_ID                    NUMBER,
                      p_DUP_PARTY_ID                NUMBER,
                      p_FROM_DATE                   DATE,
                      p_TO_DATE                     DATE,
                      p_CREATED_BY                  NUMBER,
                      p_CREATION_DATE               DATE,
                      p_LAST_UPDATE_LOGIN           NUMBER,
                      p_LAST_UPDATE_DATE            DATE,
                      p_LAST_UPDATED_BY             NUMBER);

PROCEDURE Delete_Row( p_DUP_EXCLUSION_ID            NUMBER);

END HZ_DUP_EXCLUSIONS_PKG;

 

/
