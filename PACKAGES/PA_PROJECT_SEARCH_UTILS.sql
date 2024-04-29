--------------------------------------------------------
--  DDL for Package PA_PROJECT_SEARCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SEARCH_UTILS" AUTHID CURRENT_USER AS
/*$Header: PAPRSUTS.pls 120.1 2006/02/28 05:05:02 dthakker noship $*/


PROCEDURE Convert_NameToId
( p_param_type_tbl           IN  SYSTEM.pa_varchar2_30_tbl_type
 ,p_param_value_tbl          IN  SYSTEM.pa_varchar2_240_tbl_type
 ,p_param_value2_tbl         IN  SYSTEM.pa_varchar2_240_tbl_type
 ,p_init_msg_list            IN  VARCHAR2  := FND_API.G_FALSE
 ,x_param_id_tbl            OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,x_return_status           OUT  NOCOPY VARCHAR2
 ,x_msg_count               OUT  NOCOPY NUMBER
 ,x_msg_data                OUT  NOCOPY VARCHAR2
);

PROCEDURE Check_Customer_Name_Or_Id
(  p_customer_id                   IN NUMBER
  ,p_customer_name                 IN VARCHAR2
  ,x_customer_id                   OUT NOCOPY NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2
  ,x_error_msg_code                OUT NOCOPY VARCHAR2
);

PROCEDURE Check_PersonName_Or_Id(
       p_resource_id             IN     NUMBER
      ,p_resource_name           IN     VARCHAR2
      ,x_resource_id            OUT NOCOPY     NUMBER
      ,x_resource_type_id       OUT NOCOPY     NUMBER
      ,x_return_status          OUT NOCOPY     VARCHAR2
      ,x_error_msg_code         OUT NOCOPY     VARCHAR2
);


PROCEDURE Check_ResourceName_Or_Id(
       p_person_id             IN     NUMBER
      ,p_person_name           IN     VARCHAR2
      ,x_person_id              OUT NOCOPY    NUMBER
      ,x_return_status          OUT NOCOPY    VARCHAR2
      ,x_error_msg_code         OUT NOCOPY    VARCHAR2
);

PROCEDURE Get_Perf_Measures
(
   p_source_api                  IN         VARCHAR2,
   p_project_id                  IN         NUMBER,
   p_measure_codes_tbl           IN         SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
   p_measure_set_codes_tbl       IN         SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL, -- added for bug4361663
   p_timeslices_tbl              IN         SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL, -- added for bug4361663
   p_measure_id_tbl              IN         SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL, -- added for bug4361663
   x_measure_values_tbl          OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
   x_exception_indicator_tbl     OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
--   x_exception_labels_tbl        OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE,
   x_sec_ret_code                OUT NOCOPY VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

END PA_PROJECT_SEARCH_UTILS;

 

/
