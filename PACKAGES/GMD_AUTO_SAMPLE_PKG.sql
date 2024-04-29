--------------------------------------------------------
--  DDL for Package GMD_AUTO_SAMPLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_AUTO_SAMPLE_PKG" AUTHID CURRENT_USER AS
/* $Header:  */

PROCEDURE create_samples (x_sampling_event GMD_SAMPLING_EVENTS%ROWTYPE,
	L_spec_id  number,
	L_spec_vr_id number,
	X_return_status OUT NOCOPY varchar2) ;


END GMD_AUTO_SAMPLE_PKG;

 

/
