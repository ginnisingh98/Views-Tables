--------------------------------------------------------
--  DDL for Package PA_PERIOD_MASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERIOD_MASKS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAFPPMMS.pls 120.0 2005/05/30 09:32:02 appldev noship $ */
    /***********Procedure for maintaining the period masks*********/
    PROCEDURE maintain_period_masks(
                    	p_period_mask_id		IN NUMBER,
                    	p_name				IN VARCHAR2,
                        p_description		    	IN VARCHAR2,
                        p_time_phase_code		IN VARCHAR2,
                        p_effective_start_date		IN pa_period_masks_b.effective_start_date%type ,
                        p_effective_end_date		IN pa_period_masks_b.effective_end_date%type ,
			p_record_version_number		IN NUMBER,
			p_num_of_periods		IN PA_NUM_1000_NUM,
			p_anchor_period_flag 		IN PA_VC_1000_150,
			p_from_anchor_position	        IN PA_NUM_1000_NUM,
                        p_error_flag_tab                IN OUT NOCOPY PA_VC_1000_150,
			p_init_msg_flag                 IN VARCHAR2  DEFAULT 'N',
     			p_commit_flag                   IN VARCHAR2  DEFAULT 'N',
                        x_return_status       		OUT NOCOPY VARCHAR2,
                        x_msg_count           		OUT NOCOPY NUMBER,
                        x_msg_data            		OUT NOCOPY VARCHAR2 );

    /***********Procedure for maintaining the period mask details*********/
    PROCEDURE MAINTAIN_PERIOD_MASK_DTLS(
					p_period_mask_id                IN  pa_period_masks_b.period_mask_id%TYPE,
     					p_num_of_periods                IN  PA_NUM_1000_NUM,
     					p_anchor_period_flag            IN  PA_VC_1000_150,
     					p_from_anchor_position          IN  PA_NUM_1000_NUM,
     					p_init_msg_flag                 IN  VARCHAR2  DEFAULT 'N',
     					p_commit_flag                   IN  VARCHAR2  DEFAULT 'N',
     					x_return_status                 OUT  NOCOPY VARCHAR2,
     					x_msg_count                     OUT  NOCOPY NUMBER,
     					x_msg_data                      OUT  NOCOPY VARCHAR2 );

    /***********Procedure for deleting period mask*********/
    PROCEDURE delete_period_mask(
					p_period_mask_id 		IN NUMBER,
					p_record_version_number		IN NUMBER,
					p_init_msg_flag                 IN  VARCHAR2  DEFAULT 'N',
    					p_commit_flag                   IN  VARCHAR2  DEFAULT 'N',
					x_return_status     		OUT NOCOPY VARCHAR2,
                        		x_msg_count    			OUT NOCOPY NUMBER,
                        		x_msg_data     			OUT NOCOPY VARCHAR2 );

END PA_PERIOD_MASKS_PUB;

 

/
