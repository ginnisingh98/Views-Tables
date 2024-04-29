--------------------------------------------------------
--  DDL for Package INL_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: INLVUTLS.pls 120.0.12010000.2 2013/09/09 14:38:53 acferrei noship $ */

G_MODULE_NAME CONSTANT VARCHAR2(200):= 'INL.PLSQL.INL_UTILITIES_PKG.';
G_PKG_NAME CONSTANT VARCHAR2(50) := 'INL_UTILITIES_PKG';

Function Get_LookupMeaning(p_lookup_type IN VARCHAR2,
                           p_lookup_code IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2;

Function Expose_Feature(p_feature IN VARCHAR2) RETURN VARCHAR2;

END INL_UTILITIES_PKG;

/
