--------------------------------------------------------
--  DDL for Package GMD_RESULT_TRANSFER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RESULT_TRANSFER_GRP" AUTHID CURRENT_USER AS
--$Header: GMDGRSTS.pls 115.1 2003/08/22 23:05:27 magupta noship $


--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGRSTS.pls                                        |
--| Package Name       : gmd_result_transfer_grp                             |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Results  Assoc.            |
--|                                                                          |
--| HISTORY                                                                  |
--|    Manish Gupta     19-Aug-2003     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

   PROCEDURE populate_transfer(p_child_id      IN         NUMBER,
                               p_parent_id     IN         NUMBER,
                               p_transfer_type IN         VARCHAR2,
                               x_message_count OUT NOCOPY NUMBER,
                               x_message_data  OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2);

   PROCEDURE do_transfer(p_transfer_type   IN         VARCHAR2,
                         p_copy_edit_text  IN         VARCHAR2,
			 p_copy_flex_field IN         VARCHAR2,
			 p_copy_attachment IN         VARCHAR2,
			 p_sampling_event_id  IN         NUMBER,
      			 p_sample_id  IN         NUMBER,
      			 x_sample_disp     OUT NOCOPY VARCHAR2,
			 x_message_count   OUT NOCOPY NUMBER,
			 x_message_data    OUT NOCOPY VARCHAR2,
			 x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE  copy_previous_composite_result(p_composite_spec_disp_id IN NUMBER,
   		                                     x_message_count   OUT NOCOPY NUMBER,
			                                 x_message_data    OUT NOCOPY VARCHAR2,
                                             x_return_status          OUT NOCOPY VARCHAR2);
   PROCEDURE  delete_single_composite(p_composite_spec_disp_id   NUMBER,
                                      x_message_count   OUT NOCOPY NUMBER,
			                          x_message_data    OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2);
END gmd_result_transfEr_grp;

 

/
