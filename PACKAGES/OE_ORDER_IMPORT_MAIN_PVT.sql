--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_MAIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_MAIN_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIMNS.pls 120.5.12000000.1 2007/01/16 22:10:47 appldev ship $ */

--  Start of Comments
--  API name    Order Import Main
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_ORDER_IMPORT_MAIN_PVT';
G_ORG_ID           NUMBER;

-- Added this to create new conc. program for FND_STAT
PROCEDURE ORDER_IMPORT_STATS_CONC_PGM(
errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER

);


PROCEDURE ORDER_IMPORT_CONC_PGM(
errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER
  ,p_operating_unit             IN  NUMBER DEFAULT NULL
  ,p_order_source		IN  VARCHAR2
  ,p_orig_sys_document_ref	IN  VARCHAR2
  ,p_operation_code		IN  VARCHAR2
  ,p_validate_only		IN  VARCHAR2 DEFAULT 'N'
  ,p_debug_level		IN  NUMBER
  ,p_num_instances              IN NUMBER DEFAULT 1
  ,p_sold_to_org_id             IN  NUMBER  := NULL
  ,p_sold_to_org                IN  VARCHAR2 := NULL
  ,p_change_sequence            IN  VARCHAR2  := NULL
  ,p_perf_param                 IN  VARCHAR2 := 'Y'
  ,p_rtrim_data                 IN  VARCHAR2 := 'N'
  ,p_process_orders_with_null_org   IN  VARCHAR2 DEFAULT 'Y'
  ,p_default_org_id             IN  NUMBER DEFAULT NULL
  ,p_validate_desc_flex         IN  VARCHAR2 DEFAULT 'Y'  --bug 4343612
);

PROCEDURE ORDER_IMPORT_FORM(
   p_request_id                 IN  NUMBER      DEFAULT FND_API.G_MISS_NUM
  ,p_order_source_id            IN  NUMBER
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER      DEFAULT NULL
  ,p_sold_to_org                IN  VARCHAR2    DEFAULT NULL
  ,p_change_sequence            IN  VARCHAR2    DEFAULT FND_API.G_MISS_CHAR
  ,p_org_id                     IN  NUMBER      DEFAULT NULL
  ,p_validate_only              IN  VARCHAR2    DEFAULT FND_API.G_FALSE
  ,p_init_msg_list              IN  VARCHAR2    DEFAULT FND_API.G_TRUE
  ,p_rtrim_data                 In  Varchar2    Default Null
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2


);
-- Retreive the client info for bug no 5493479
G_CONTEXT_ID    NUMBER :=  NULL;
END OE_ORDER_IMPORT_MAIN_PVT;

 

/
