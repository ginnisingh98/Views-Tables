--------------------------------------------------------
--  DDL for Package Body PA_CI_NUMBER_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_NUMBER_CLIENT_EXTN" as
/* $Header: PACINRXB.pls 115.4 2003/03/11 02:21:27 mwasowic noship $ */


procedure GET_NEXT_NUMBER (
         p_object1_type         IN  VARCHAR2   := FND_API.g_miss_char
        ,p_object1_pk1_value    IN  NUMBER     := FND_API.g_miss_num
        ,p_object2_type         IN  VARCHAR2   := FND_API.g_miss_char
        ,p_object2_pk1_value    IN  NUMBER     := FND_API.g_miss_num
        ,p_next_number          IN  OUT NOCOPY VARCHAR2
        ,x_return_status        OUT  NOCOPY VARCHAR2
        ,x_msg_count            OUT  NOCOPY NUMBER
        ,x_msg_data             OUT  NOCOPY VARCHAR2) IS

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_next_number   := p_next_number;

END GET_NEXT_NUMBER;
end;


/
