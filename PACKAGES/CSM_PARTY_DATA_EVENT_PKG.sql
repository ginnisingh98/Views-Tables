--------------------------------------------------------
--  DDL for Package CSM_PARTY_DATA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PARTY_DATA_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmepdas.pls 120.1 2008/03/04 06:34:43 anaraman noship $ */

PROCEDURE REFRESH_ACC( x_return_status OUT NOCOPY VARCHAR2,
                       x_error_message OUT NOCOPY VARCHAR2
                     );


END CSM_PARTY_DATA_EVENT_PKG; -- Package spec

/
