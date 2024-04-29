--------------------------------------------------------
--  DDL for Package PA_BILLING_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: PABIPROS.pls 120.0.12010000.1 2008/11/12 12:59:00 nkapling noship $ */

  PA_DEBUG_MODE     VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  G_REQUEST_ID      NUMBER      := fnd_global.conc_request_id;
  PROCEDURE PA_PROCESS_REV_ADJ (pproject_id  IN NUMBER,
                              pfromproj    IN VARCHAR2,
			      ptoproj      IN VARCHAR2,
			      pmass_gen    IN NUMBER,
			      pacc_thru_dt IN DATE);
END PA_BILLING_PROCESS_PKG;

/
