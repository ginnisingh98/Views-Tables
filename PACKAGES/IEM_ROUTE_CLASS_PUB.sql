--------------------------------------------------------
--  DDL for Package IEM_ROUTE_CLASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ROUTE_CLASS_PUB" AUTHID CURRENT_USER AS
/* $Header: iempclss.pls 115.4 2002/11/20 19:30:22 liangxia noship $ */

PROCEDURE classify(
  p_api_version_number  IN Number,
  p_init_msg_list       IN VARCHAR2 := NULL,
  p_commit              IN VARCHAR2 := NULL,
  p_keyVals_tbl         IN IEM_ROUTE_PUB.keyVals_tbl_type,
  p_accountId           IN Number,
  x_classificationId    OUT NOCOPY Number,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2);

END IEM_ROUTE_CLASS_PUB;

 

/
