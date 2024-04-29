--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_POLLCREATENOTIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_POLLCREATENOTIF" AS
/* $Header: dppvbpnb.pls 120.0 2008/03/25 06:26:06 vdewan noship $ */
	FUNCTION wait_for_request(p_request_id NUMBER,   p_interval NUMBER,   p_max_wait NUMBER,   x_phase OUT NOCOPY VARCHAR2,
	x_status OUT NOCOPY VARCHAR2,   x_dev_phase OUT NOCOPY VARCHAR2,   x_dev_status OUT NOCOPY VARCHAR2,
	x_message OUT NOCOPY VARCHAR2,   x_error_message OUT NOCOPY VARCHAR2) RETURN INTEGER IS x_return INTEGER;
	   BEGIN
	    x_return := sys.sqljutl.bool2int(apps.fnd_concurrent.wait_for_request(p_request_id,   p_interval,   p_max_wait,
	    x_phase,   x_status,   x_dev_phase,   x_dev_status,   x_message));

	    IF(x_return = 0) THEN
	      fnd_message.set_name('DPP',   'DPP_BPEL_CONC_PGM_NOINFO');
	      fnd_message.set_token('TOKEN_01',   p_request_id);
	      x_error_message := fnd_message.GET;

	    ELSIF(x_dev_status = 'DELETED') THEN
	      fnd_message.set_name('DPP',   'DPP_BPEL_CONC_PGM_DELETED');
	      fnd_message.set_token('TOKEN_01',   p_request_id);
	      x_error_message := fnd_message.GET;

	    ELSIF(x_dev_status = 'TERMINATED') THEN
	      fnd_message.set_name('DPP',   'DPP_BPEL_CONC_PGM_TERMINATED');
	      fnd_message.set_token('TOKEN_01',   p_request_id);
	      x_error_message := fnd_message.GET;

	    ELSIF(x_dev_status = 'ERROR') THEN
	      fnd_message.set_name('DPP',   'DPP_BPEL_CONC_PGM_ERROR');
	      fnd_message.set_token('TOKEN_01',   p_request_id);
	      x_error_message := fnd_message.GET;

	    ELSIF(x_dev_status = 'NO_MANAGER') THEN
	      fnd_message.set_name('DPP',   'DPP_BPEL_CONC_PGM_NO_MANAGER');
	      fnd_message.set_token('TOKEN_01',   p_request_id);
	      x_error_message := fnd_message.GET;

	    ELSIF(x_dev_status = 'DISABLED') THEN
	      fnd_message.set_name('DPP',   'DPP_BPEL_CONC_PGM_DISABLED');
	      fnd_message.set_token('TOKEN_01',   p_request_id);
	      x_error_message := fnd_message.GET;
	    END IF;

	    RETURN x_return;
	   END wait_for_request;

	END dpp_bpel_pollcreatenotif;

/
