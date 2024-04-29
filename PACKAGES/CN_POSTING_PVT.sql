--------------------------------------------------------
--  DDL for Package CN_POSTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_POSTING_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvpdets.pls 120.0 2005/06/06 17:50:14 appldev noship $

PROCEDURE posting_conc
  (errbuf               OUT NOCOPY   VARCHAR2,
   retcode              OUT NOCOPY   NUMBER,
   start_date           IN    VARCHAR2,
   end_date             IN    VARCHAR2);

PROCEDURE post_worker
  (p_parent_proc_audit_id      number,
   p_posting_batch_id          number,
   p_physical_batch_id         number,
   p_start_date                date,
   p_end_date                  date);

PROCEDURE posting_details
  (p_api_version           IN    NUMBER,
   p_init_msg_list         IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	               IN    VARCHAR2 := FND_API.G_FALSE,
   x_return_status         OUT NOCOPY   VARCHAR2,
   x_msg_count	           OUT NOCOPY   NUMBER,
   x_msg_data	           OUT NOCOPY   VARCHAR2,
   p_start_date            IN    DATE,
   p_end_date              IN    DATE,
   p_parent_proc_audit_id  IN    NUMBER);

END cn_posting_pvt;

 

/
