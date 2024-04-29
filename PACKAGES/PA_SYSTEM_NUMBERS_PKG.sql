--------------------------------------------------------
--  DDL for Package PA_SYSTEM_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SYSTEM_NUMBERS_PKG" AUTHID CURRENT_USER AS
--$Header: PASNUMTS.pls 115.4 2002/12/21 00:24:38 mwasowic noship $

procedure GET_NEXT_NUMBER (
         p_system_number_id     IN  NUMBER     := NULL
        ,p_object1_pk1_value    IN  NUMBER     := NULL
        ,p_object1_type         IN  VARCHAR2   := NULL
        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL

        ,x_system_number_id      OUT NOCOPY NUMBER
        ,x_next_number           OUT NOCOPY NUMBER
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
);

procedure INSERT_ROW (
         p_object1_pk1_value    IN  NUMBER
        ,p_object1_type         IN  VARCHAR2

        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL
        ,p_next_number          IN  NUMBER     := NULL

        ,x_next_number          OUT NOCOPY NUMBER
        ,x_system_number_id      OUT NOCOPY NUMBER
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2

);

procedure UPDATE_ROW (
         p_system_number_id     IN  NUMBER     := NULL
        ,p_object1_pk1_value    IN  NUMBER     := NULL
        ,p_object1_type         IN  VARCHAR2   := NULL

        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL
        ,p_next_number          IN  NUMBER     := NULL

        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2


);

procedure DELETE_ROW (
         p_system_number_id     IN  NUMBER    := NULL
        ,p_object1_pk1_value    IN  NUMBER    := NULL
        ,p_object1_type         IN  VARCHAR2  := NULL
        ,p_object2_pk1_value    IN  NUMBER     := NULL
        ,p_object2_type         IN  VARCHAR2   := NULL

  ,x_return_status               OUT NOCOPY    VARCHAR2
  ,x_msg_count                   OUT NOCOPY    NUMBER
  ,x_msg_data                    OUT NOCOPY    VARCHAR2
);

END  PA_SYSTEM_NUMBERS_PKG;

 

/
