--------------------------------------------------------
--  DDL for Package PA_FP_PERIOD_MASKS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_PERIOD_MASKS_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFPPMUS.pls 120.0 2005/05/29 12:30:00 appldev noship $ */


--***********Procedure for checking duplicate names*************
PROCEDURE NAME_VALIDATION
    (p_name                           IN     pa_period_masks_tl.name%TYPE,
     p_period_mask_id                 IN     pa_period_masks_b.period_mask_id%TYPE,
     p_init_msg_flag                  IN     VARCHAR2  DEFAULT 'N',
     x_return_status                  OUT    NOCOPY VARCHAR2,
     x_msg_count                      OUT    NOCOPY NUMBER,
     x_msg_data	                      OUT    NOCOPY VARCHAR2);



--************Procedure for validating number of period*********
PROCEDURE NOP_VALIDATION
    (p_num_of_periods                 IN     PA_NUM_1000_NUM,
     p_init_msg_flag                  IN     VARCHAR2  DEFAULT 'N',
     p_error_flag_tab                 IN OUT NOCOPY PA_VC_1000_150,
     x_return_status                  OUT    NOCOPY VARCHAR2,
     x_msg_count                      OUT    NOCOPY NUMBER,
     x_msg_data                       OUT    NOCOPY VARCHAR2);


--***********Procedure for maintaining the period mask details*********
/* PROCEDURE MAINTAIN_PERIOD_MASK_DTLS
    (p_period_mask_id                IN     pa_period_masks_b.period_mask_id%TYPE,
     p_num_of_periods                IN     PA_NUM_1000_NUM,
     p_anchor_period_flag            IN     PA_VC_1000_150,
     p_from_anchor_position          IN     PA_NUM_1000_NUM,
     p_init_msg_flag                  IN     VARCHAR2  DEFAULT 'N',
     p_commit_flag                   IN      VARCHAR2  DEFAULT 'N',
     x_return_status                 OUT    NOCOPY VARCHAR2,
     x_msg_count                     OUT    NOCOPY NUMBER,
     x_msg_data                      OUT    NOCOPY VARCHAR2);   */


--************Function to allow delete*************************
FUNCTION IS_DELETE_ALLOWED
     (p_period_mask_id                IN     pa_period_masks_b.period_mask_id%TYPE)
     RETURN VARCHAR2;



END PA_FP_PERIOD_MASKS_UTILS;

 

/
