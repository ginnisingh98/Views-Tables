--------------------------------------------------------
--  DDL for Package FUN_RULE_OBJECTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_OBJECTS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: FUNXTMRULROBRWS.pls 120.3 2006/01/10 14:35:22 ammishra noship $ */
  procedure create_rule_object(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  DATE
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , x_rule_object_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_rule_object(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  DATE
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_rule_object_rec(p_init_msg_list  VARCHAR2
    , p_rule_object_name  VARCHAR2
    , p_application_id  NUMBER
    , p_instance_label  VARCHAR2
    , p_org_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  NUMBER
    , p5_a18 out nocopy  DATE
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  DATE
    , p5_a21 out nocopy  NUMBER
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_rule_object_rec(p_init_msg_list  VARCHAR2
    , p_rule_object_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  NUMBER
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  NUMBER
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  NUMBER
    , p2_a18 out nocopy  DATE
    , p2_a19 out nocopy  NUMBER
    , p2_a20 out nocopy  DATE
    , p2_a21 out nocopy  NUMBER
    , p2_a22 out nocopy  NUMBER
    , p2_a23 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure rule_object_instance_exists(p_application_id  NUMBER
    , p_rule_object_name  VARCHAR2
    , p_instance_label  VARCHAR2
    , p_org_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure rule_object_uses_parameter(p_rule_object_name  VARCHAR2
    , p_parameter_name  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end fun_rule_objects_pub_w;

 

/
