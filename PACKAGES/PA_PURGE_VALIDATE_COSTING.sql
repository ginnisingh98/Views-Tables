--------------------------------------------------------
--  DDL for Package PA_PURGE_VALIDATE_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_VALIDATE_COSTING" AUTHID CURRENT_USER as
/* $Header: PAXCSVTS.pls 120.1 2005/08/03 11:13:57 aaggarwa noship $ */

 -- forward declarations

 procedure Validate_Costing( p_project_id                     in NUMBER,
                             p_txn_to_date                    in DATE,
                             p_active_flag                    in VARCHAR2,
                             x_err_code                       in OUT NOCOPY NUMBER,
                             x_err_stack                      in OUT NOCOPY VARCHAR2,
                             x_err_stage                      in OUT NOCOPY VARCHAR2 ) ;

 procedure Validate_Allocations( p_proj_id                        in NUMBER,
                                 x_source                         OUT NOCOPY NUMBER,
                                 x_target                         OUT NOCOPY NUMBER,
                                 x_offset                         OUT NOCOPY NUMBER);


END ;
 

/
