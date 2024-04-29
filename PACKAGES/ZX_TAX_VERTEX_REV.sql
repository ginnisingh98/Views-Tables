--------------------------------------------------------
--  DDL for Package ZX_TAX_VERTEX_REV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_VERTEX_REV" AUTHID CURRENT_USER AS
/* $Header: zxtxvrevs.pls 120.2 2005/12/28 12:34:48 vchallur ship $ */


PROCEDURE GET_RELEASE (p_context_rec   OUT NOCOPY ZX_TAX_VERTEX_QSU.tQSUContextRecord,
                       p_version_rec   OUT NOCOPY ZX_TAX_VERTEX_QSU.tQSUVersionRecord,
		       x_return_status OUT NOCOPY VARCHAR2);

END ZX_TAX_VERTEX_REV;

 

/
