--------------------------------------------------------
--  DDL for Package CS_SR_COST_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_COST_CP" AUTHID CURRENT_USER AS
/* $Header: csvcstpgs.pls 120.0 2007/12/19 11:38:26 gasankar noship $ */

PROCEDURE Create_Cost
(
  errbuf                          OUT NOCOPY VARCHAR2
, errcode                         OUT NOCOPY NUMBER
, p_api_version_number            IN         NUMBER
, p_init_msg_list                 IN         VARCHAR2
, p_commit                        IN         VARCHAR2
, p_validation_level              IN         NUMBER
, p_creation_from_date	          IN	     varchar2
, p_creation_to_date		  IN	     varchar2
, p_sr_status			  IN	     VARCHAR2
, p_number_of_workers             IN         NUMBER
, p_cost_batch_size               IN         NUMBER
);

PROCEDURE Cost_Worker
(
  errbuf                          OUT NOCOPY VARCHAR2
, errcode                         OUT NOCOPY NUMBER
, p_api_version_number            IN	     NUMBER
, p_init_msg_list                 IN	     VARCHAR2
, p_commit                        IN	     VARCHAR2
, p_validation_level              IN         NUMBER
, p_worker_id                     IN         NUMBER
, p_cost_batch_size               IN         NUMBER
, p_cost_set_id                   IN         NUMBER
);

PROCEDURE   Validate_params
(
  p_creation_from_date  IN  VARCHAR2
, p_creation_to_date    IN  VARCHAR2
, p_sr_status		IN  VARCHAR2
, x_creation_from_date  OUT NOCOPY DATE
, x_creation_to_date    OUT NOCOPY DATE
, x_msg_count		OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
);

PROCEDURE Form_And_Exec_Statement
(
  p_creation_from_date            IN              DATE
, p_creation_to_date              IN              DATE
, p_sr_status		          IN              VARCHAR2
, p_number_of_workers             IN OUT NOCOPY   NUMBER
, p_cost_batch_size               IN              NUMBER
, p_request_id                    IN              NUMBER
, p_row_count                     OUT NOCOPY      NUMBER
);


END CS_SR_COST_CP;

/
