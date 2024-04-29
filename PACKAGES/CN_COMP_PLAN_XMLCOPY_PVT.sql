--------------------------------------------------------
--  DDL for Package CN_COMP_PLAN_XMLCOPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLAN_XMLCOPY_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvcpxmls.pls 120.5 2007/08/07 20:46:01 jxsingh noship $*/

PROCEDURE Import_PlanCopy
  (errbuf               OUT NOCOPY VARCHAR2,
   retcode              OUT NOCOPY NUMBER,
   p_exp_imp_request_id IN cn_copy_requests_all.exp_imp_request_id%TYPE);

PROCEDURE Parse_XML
  (p_api_version          IN          NUMBER   := 1.0,
   p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
   p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
   p_validation_level     IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_xml                  IN          cn_copy_requests_all.file_content_xmltype%TYPE,
   p_prefix               IN          cn_copy_requests_all.prefix_info%TYPE,
   p_start_date           IN          DATE,
   p_end_date             IN          DATE,
   p_org_id               IN          cn_copy_requests_all.org_id%TYPE,
   p_object_count         IN          NUMBER,
   x_import_status        OUT NOCOPY  VARCHAR2);

END CN_COMP_PLAN_XMLCOPY_PVT;

/
