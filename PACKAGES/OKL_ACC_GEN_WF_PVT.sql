--------------------------------------------------------
--  DDL for Package OKL_ACC_GEN_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACC_GEN_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAGWS.pls 120.2 2005/10/30 04:31:14 appldev noship $ */

/* This function will be called from the Account Generator API to invoke
   the workflow to generate the ccid
*/

SUBTYPE  acc_gen_wf_sources_rec IS OKL_ACCOUNT_GENERATOR_PUB.acc_gen_wf_sources_rec;
SUBTYPE acc_gen_primary_key IS OKL_ACCOUNT_GENERATOR_PUB.primary_key_tbl;


-- Changed the signature for bug 4157521

FUNCTION start_process
  (
    p_acc_gen_wf_sources_rec       IN  acc_gen_wf_sources_rec,
    p_ae_line_type	      IN  okl_acc_gen_rules.ae_line_type%TYPE,
    p_primary_key_tbl	      IN  acc_gen_primary_key,
    p_ae_tmpt_line_id	      IN  NUMBER DEFAULT NULL
  )
  RETURN NUMBER;


/*
   This sample function will be used to get the template line CCID
   based on the template line ID available in workflow.
*/

  PROCEDURE sample_function (itemtype  IN VARCHAR2,
	      	    itemkey   IN VARCHAR2,
		    actid     IN NUMBER,
		    funcmode  IN VARCHAR2,
		    result    OUT NOCOPY VARCHAR2);


END OKL_ACC_GEN_WF_PVT;


 

/
