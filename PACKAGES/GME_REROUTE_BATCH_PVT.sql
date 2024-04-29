--------------------------------------------------------
--  DDL for Package GME_REROUTE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_REROUTE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVRRBS.pls 120.1 2005/06/03 13:49:21 appldev  $ */
   PROCEDURE reroute_batch (
      p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_validity_rule_id      IN              NUMBER
     ,p_use_workday_cal       IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,p_contiguity_override   IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_batch_header_rec      OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_validity_id_from_pub (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_validity_rule_id   IN              NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE validate_validity_id (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_validity_rule_id   IN              NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_all_steps (
      p_batch_id        IN              NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);
END gme_reroute_batch_pvt;

 

/
