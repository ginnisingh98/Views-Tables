--------------------------------------------------------
--  DDL for Package CN_CALC_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_ROLLUP_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvcrols.pls 120.2.12010000.1 2008/07/24 11:04:42 appldev ship $

   -- API name  : rollup_batch
   -- Type   : Private.
   -- Pre-reqs  :
   -- Usage  :
   --+
   -- Desc   :
   --
   --
   --+
   -- Parameters   :
   --  IN :  p_api_version       NUMBER      Require
   --        p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
   --        p_commit        VARCHAR2    Optional (FND_API.G_FALSE)
   --        p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
   --  OUT   :  x_return_status     VARCHAR2(1)
   --        x_msg_count        NUMBER
   --        x_msg_data         VARCHAR2(2000)
   --  IN :  p_physical_batch_id NUMBER(15) Require
   --
   --
   --  +
   --+
   -- Version   : Current version 1.0
   --       Initial version    1.0
   --+
   -- Notes  :
   --+
   -- End of comments
   PROCEDURE rollup_batch (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       VARCHAR2 := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_physical_batch_id        IN       NUMBER,
      p_mode                     IN       VARCHAR2 := 'NORMAL',
      p_event_log_id             IN       NUMBER := NULL
   );
END cn_calc_rollup_pvt;

/
