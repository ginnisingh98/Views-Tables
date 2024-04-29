--------------------------------------------------------
--  DDL for Package Body CSI_SYSTEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_SYSTEMS_PVT" AS
/* $Header: csivsysb.pls 120.3.12010000.2 2008/11/06 20:33:46 mashah ship $ */
-- start of comments
-- package name     : csi_systems_pvt
-- purpose          :
-- history          :
-- note             :
-- END of comments


g_pkg_name  CONSTANT VARCHAR2(30) := 'CSI_SYSTEMS_PVT';
g_file_name CONSTANT VARCHAR2(12) := 'csivsysb.pls';

PROCEDURE validate_system_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_system_id                  IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_customer_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_customer_id                IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_system_type_code (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_system_type_code           IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );



PROCEDURE validate_parent_system_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_parent_system_id           IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_ship_to_contact_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_ship_to_contact_id         IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_bill_to_contact_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_bill_to_contact_id         IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_technical_contact_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_technical_contact_id       IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_srv_admin_cont_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_service_admin_contact_id   IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_ship_to_site_use_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_ship_to_site_use_id        IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_bill_to_site_use_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_bill_to_site_use_id        IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_install_site_use_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_install_site_use_id        IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_start_end_date (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_system_id                  IN   NUMBER    ,
    p_start_date                 IN   DATE      ,
    p_end_date                   IN   DATE      ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_object_version_num (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_object_version_number      IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_name (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_name                       IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_auto_sys_id (
    p_init_msg_list              IN   VARCHAR2 := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_auto_sys_id                IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE define_columns(
p_system_rec                IN   csi_datastructures_pub.system_rec,
p_cur_get_systems           IN   NUMBER
)
IS
BEGIN

    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  1, p_system_rec.system_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  2, p_system_rec.customer_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  3, p_system_rec.system_type_code,30);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  4, p_system_rec.system_number,30);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  5, p_system_rec.parent_system_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  6, p_system_rec.ship_to_contact_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  7, p_system_rec.bill_to_contact_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  8, p_system_rec.technical_contact_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems,  9, p_system_rec.service_admin_contact_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 10, p_system_rec.ship_to_site_use_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 11, p_system_rec.bill_to_site_use_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 12, p_system_rec.install_site_use_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 13, p_system_rec.coterminate_day_month,6);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 14, p_system_rec.autocreated_from_system_id);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 15, p_system_rec.start_date_active);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 16, p_system_rec.end_date_active);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 17, p_system_rec.context,30);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 18, p_system_rec.attribute1,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 19, p_system_rec.attribute2,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 20, p_system_rec.attribute3,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 21, p_system_rec.attribute4,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 22, p_system_rec.attribute5,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 23, p_system_rec.attribute6,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 24, p_system_rec.attribute7,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 25, p_system_rec.attribute8,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 26, p_system_rec.attribute9,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 27, p_system_rec.attribute10,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 28, p_system_rec.attribute11,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 29, p_system_rec.attribute12,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 30, p_system_rec.attribute13,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 31, p_system_rec.attribute14,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 32, p_system_rec.attribute15,240);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 33, p_system_rec.object_version_number);
    DBMS_SQL.DEFINE_COLUMN(p_cur_get_systems, 34, p_system_rec.operating_unit_id);
END define_columns;

PROCEDURE get_column_values(
    p_cur_get_systems         IN   NUMBER,
    x_sys_rec                OUT NOCOPY   csi_datastructures_pub.system_rec
)
IS
BEGIN
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  1, x_sys_rec.system_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  2, x_sys_rec.customer_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  3, x_sys_rec.system_type_code);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  4, x_sys_rec.system_number);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  5, x_sys_rec.parent_system_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  6, x_sys_rec.ship_to_contact_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  7, x_sys_rec.bill_to_contact_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  8, x_sys_rec.technical_contact_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems,  9, x_sys_rec.service_admin_contact_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 10, x_sys_rec.ship_to_site_use_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 11, x_sys_rec.bill_to_site_use_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 12, x_sys_rec.install_site_use_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 13, x_sys_rec.coterminate_day_month);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 14, x_sys_rec.autocreated_from_system_id);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 15, x_sys_rec.start_date_active);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 16, x_sys_rec.end_date_active);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 17, x_sys_rec.context);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 18, x_sys_rec.attribute1);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 19, x_sys_rec.attribute2);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 20, x_sys_rec.attribute3);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 21, x_sys_rec.attribute4);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 22, x_sys_rec.attribute5);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 23, x_sys_rec.attribute6);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 24, x_sys_rec.attribute7);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 25, x_sys_rec.attribute8);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 26, x_sys_rec.attribute9);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 27, x_sys_rec.attribute10);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 28, x_sys_rec.attribute11);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 29, x_sys_rec.attribute12);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 30, x_sys_rec.attribute13);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 31, x_sys_rec.attribute14);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 32, x_sys_rec.attribute15);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 33, x_sys_rec.object_version_number);
    DBMS_SQL.COLUMN_VALUE(p_cur_get_systems, 34, x_sys_rec.operating_unit_id);

END get_column_values;


PROCEDURE bind(
    p_system_query_rec            IN   csi_datastructures_pub.system_query_rec,
    p_cur_get_systems             IN   NUMBER
)
IS
BEGIN



      IF( (p_system_query_rec.system_id IS NOT NULL) AND (p_system_query_rec.system_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_systems, 'system_id', p_system_query_rec.system_id);
      END IF;

      IF( (p_system_query_rec.system_type_code IS NOT NULL) AND (p_system_query_rec.system_type_code <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_systems, 'system_type_code', p_system_query_rec.system_type_code);
      END IF;

       IF( (p_system_query_rec.system_number IS NOT NULL) AND (p_system_query_rec.system_number <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_systems, 'system_number', p_system_query_rec.system_number);
      END IF;

END bind;


PROCEDURE gen_select(
    p_system_query_rec               IN    csi_datastructures_pub.system_query_rec,
    x_select_cl                      OUT NOCOPY   VARCHAR2
)
IS
BEGIN

 x_select_cl := 'SELECT distinct system_id,customer_id,system_type_code,system_number,
                 parent_system_id,ship_to_contact_id,bill_to_contact_id,technical_contact_id,
                 service_admin_contact_id,ship_to_site_use_id,bill_to_site_use_id,
                 install_site_use_id,coterminate_day_month,autocreated_from_system_id,
                 start_date_active,end_date_active,context,attribute1,attribute2,attribute3,
                 attribute4,attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
                 attribute11,attribute12,attribute13,attribute14,attribute15,object_version_number,
		 operating_unit_id
                  FROM csi_systems_b ';



END gen_select;

PROCEDURE gen_systems_where(
    p_system_query_rec               IN     csi_datastructures_pub.system_query_rec,
    p_active_systems_only            IN     VARCHAR2,
    x_systems_where                  OUT NOCOPY    VARCHAR2
)
IS
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT instr(p_rec_item, '%', 1, 1)
    FROM dual;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT instr(p_rec_item, '_', 1, 1)
    FROM dual;

str_csr1   NUMBER;
str_csr2   NUMBER;
i          NUMBER;
l_operator VARCHAR2(10);

BEGIN


      IF( (p_system_query_rec.system_id IS NOT NULL) AND (p_system_query_rec.system_id <> fnd_api.g_miss_num) )
      THEN
          IF(x_systems_where IS NULL) THEN
              x_systems_where := ' WHERE ';
          ELSE
              x_systems_where := x_systems_where || ' AND ';
          END IF;
          x_systems_where := x_systems_where || 'system_id = :system_id';
      END IF;


      IF( (p_system_query_rec.system_type_code IS NOT NULL) AND (p_system_query_rec.system_type_code <> fnd_api.g_miss_char) )
      THEN

      i:=0;
          -- check IF item value contains '%' wildcard
            OPEN c_chk_str1(p_system_query_rec.system_type_code);
            FETCH c_chk_str1 INTO str_csr1;
            CLOSE c_chk_str1;
            IF(str_csr1 <> 0) THEN
              l_operator := ' like ';
              i:=1;
            ELSE
              l_operator := ' = ';
            END IF;
            IF i=0 THEN
          -- check IF item value contains '_' wildcard
            OPEN c_chk_str2(p_system_query_rec.system_type_code);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;
            IF(str_csr2 <> 0) THEN
              l_operator := ' like ';
            ELSE
              l_operator := ' = ';
            END IF;
            END IF;
            IF(x_systems_where IS NULL) THEN
              x_systems_where := ' WHERE ';
            ELSE
              x_systems_where := x_systems_where || ' AND ';
            END IF;
              x_systems_where := x_systems_where || 'system_type_code ' || l_operator || ' :system_type_code';
      END IF;

      IF( (p_system_query_rec.system_number IS NOT NULL) AND (p_system_query_rec.system_number <> fnd_api.g_miss_char) )
      THEN

      i:=0;

            OPEN c_chk_str1(p_system_query_rec.system_number);
            FETCH c_chk_str1 INTO str_csr1;
            CLOSE c_chk_str1;
            IF(str_csr1 <> 0) THEN
              l_operator := ' like ';
              i:=1;
            ELSE
              l_operator := ' = ';
            END IF;
            IF i=0 THEN
            OPEN c_chk_str2(p_system_query_rec.system_number);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;
            IF(str_csr2 <> 0) THEN
              l_operator := ' like ';
            ELSE
              l_operator := ' = ';
            END IF;
            END IF;
            IF(x_systems_where IS NULL) THEN
              x_systems_where := ' WHERE ';
            ELSE
              x_systems_where := x_systems_where || ' AND ';
            END IF;
              x_systems_where := x_systems_where || 'system_number ' || l_operator || ' :system_number';
      END IF;

  /*    IF  p_active_systems_only = 'T' THEN
          IF(x_systems_where IS NULL) THEN
             x_systems_where := ' WHERE ';
          ELSE
             x_systems_where := x_systems_where ||' AND ';
          END IF;
             x_systems_where := x_systems_where ||' end_date_active >= SYSDATE ';
      END IF; */



END gen_systems_where;

PROCEDURE from_to_tran( p_system_id          IN  NUMBER,
                        p_time_stamp         IN  DATE,
                        from_time_stamp      OUT NOCOPY VARCHAR2,
                        to_time_stamp        OUT NOCOPY VARCHAR2)
IS
l_f_date        VARCHAR2(25)    := fnd_api.g_miss_char;
l_t_date        VARCHAR2(25)    := fnd_api.g_miss_char;
BEGIN
             SELECT max(min(to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss')))
             INTO   l_f_date
             FROM   csi_transactions a, csi_systems_b b,csi_systems_h c
             WHERE  b.system_id = c.system_id
             AND    c.transaction_id = a.transaction_id
             AND    c.full_dump_flag = 'Y'
             AND    a.transaction_date <=p_time_stamp
             AND    c.system_id = p_system_id
             GROUP BY  to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss');
             IF l_f_date IS NULL THEN
             from_time_stamp:=NULL;
             to_time_stamp:=l_t_date;
             ELSE
             from_time_stamp:=l_f_date;
             BEGIN
                  SELECT max(min(to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss')))
                  INTO   l_t_date
                  FROM   csi_transactions a, csi_systems_b b,csi_systems_h c
                  WHERE  b.system_id = c.system_id
                  AND    c.transaction_id = a.transaction_id
                  AND    a.transaction_date <=p_time_stamp
                  AND    c.system_id = p_system_id
                  GROUP BY  to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss');

                  IF l_t_date IS NULL THEN
                  to_time_stamp:=NULL;
                  ELSE
                  to_time_stamp:=l_t_date;
                  END IF;
             END;
             END IF;
END;


PROCEDURE get_history( p_sys_rec    IN   csi_datastructures_pub.system_rec
                      ,p_new_rec    OUT NOCOPY  csi_datastructures_pub.system_rec
                      ,p_flag       OUT NOCOPY  VARCHAR2
                      ,p_time_stamp IN   DATE
                      )
IS
CURSOR hist_csr (p_system_id    IN NUMBER,
                 p_f_time_stamp IN VARCHAR2,
                 p_t_time_stamp IN VARCHAR2)
     IS
       SELECT    c.system_id
                ,c.old_customer_id
                ,c.new_customer_id
                ,c.old_system_type_code
                ,c.new_system_type_code
                ,c.old_system_number
                ,c.new_system_number
                ,c.old_parent_system_id
                ,c.new_parent_system_id
                ,c.old_ship_to_contact_id
                ,c.new_ship_to_contact_id
                ,c.old_bill_to_contact_id
                ,c.new_bill_to_contact_id
                ,c.old_technical_contact_id
                ,c.new_technical_contact_id
                ,c.old_service_admin_contact_id
                ,c.new_service_admin_contact_id
                ,c.old_ship_to_site_use_id
                ,c.new_ship_to_site_use_id
                ,c.old_install_site_use_id
                ,c.new_install_site_use_id
                ,c.old_bill_to_site_use_id
                ,c.new_bill_to_site_use_id
                ,c.old_coterminate_day_month
                ,c.new_coterminate_day_month
                ,c.old_start_date_active
                ,c.new_start_date_active
                ,c.old_end_date_active
                ,c.new_end_date_active
                ,c.old_autocreated_from_system
                ,c.new_autocreated_from_system
                ,c.old_config_system_type
                ,c.new_config_system_type
                ,c.old_context
                ,c.new_context
                ,c.old_attribute1
                ,c.new_attribute1
                ,c.old_attribute2
                ,c.new_attribute2
                ,c.old_attribute3
                ,c.new_attribute3
                ,c.old_attribute4
                ,c.new_attribute4
                ,c.old_attribute5
                ,c.new_attribute5
                ,c.old_attribute6
                ,c.new_attribute6
                ,c.old_attribute7
                ,c.new_attribute7
                ,c.old_attribute8
                ,c.new_attribute8
                ,c.old_attribute9
                ,c.new_attribute9
                ,c.old_attribute10
                ,c.new_attribute10
                ,c.old_attribute11
                ,c.new_attribute11
                ,c.old_attribute12
                ,c.new_attribute12
                ,c.old_attribute13
                ,c.new_attribute13
                ,c.old_attribute14
                ,c.new_attribute14
                ,c.old_attribute15
                ,c.new_attribute15
                ,c.full_dump_flag
		,c.old_operating_unit_id
		 ,c.new_operating_unit_id
       FROM     csi_transactions a,csi_systems_b b,csi_systems_h c
       WHERE    b.system_id      = c.system_id
       AND      c.transaction_id = a.transaction_id
       AND      c.system_id      = p_system_id
       AND      a.transaction_date BETWEEN to_date(p_f_time_stamp,'dd/mm/yyyy hh24:mi:ss')
                                   AND     to_date(p_t_time_stamp,'dd/mm/yyyy hh24:mi:ss')
       ORDER BY to_char(a.transaction_date,'dd/mm/yyyy hh24:mi:ss') ;

l_f_time_stamp      VARCHAR2(25)    :=fnd_api.g_miss_char;
l_t_time_stamp      VARCHAR2(25)    :=fnd_api.g_miss_char;
l_to_date           VARCHAR2(25);
BEGIN
      from_to_tran(p_system_id      =>  p_sys_rec.system_id,
                   p_time_stamp     =>  p_time_stamp,
                   from_time_stamp  =>  l_f_time_stamp,
                   to_time_stamp    =>  l_t_time_stamp);

     SELECT max(to_char(a.transaction_date,'dd/mm/yyyy hh24:mi:ss'))
     INTO   l_to_date
     FROM   csi_transactions a,csi_systems_h b
     WHERE  a.transaction_id=b.transaction_id
     AND    b.system_id=p_sys_rec.system_id;

       IF ( (l_f_time_stamp IS NOT NULL) AND (p_time_stamp>to_date(l_to_date,'dd/mm/yyyy hh24:mi:ss')) ) THEN
           p_new_rec := p_sys_rec;
           p_flag    := 'ADD';
       ELSIF (l_f_time_stamp IS NULL) THEN
    -- we have entered into case 1 which we have to skip the record.
           p_flag   := 'SKIP';
       ELSE
    -- we have entered into case 3 where we have to compare the record and return flag with 'add'.
           FOR get_csr IN hist_csr(p_sys_rec.system_id,l_f_time_stamp,l_t_time_stamp) LOOP

             p_new_rec.system_id:=p_sys_rec.system_id;


             IF get_csr.new_customer_id IS NOT NULL THEN
                p_new_rec.customer_id := get_csr.new_customer_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.customer_id := get_csr.old_customer_id;
             END IF;

             IF get_csr.new_system_type_code IS NOT NULL THEN
                p_new_rec.system_type_code := get_csr.new_system_type_code;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.system_type_code := get_csr.old_system_type_code;
             END IF;

             IF get_csr.new_system_number IS NOT NULL THEN
                p_new_rec.system_number := get_csr.new_system_number;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.system_number := get_csr.old_system_number;
             END IF;

             IF get_csr.new_parent_system_id IS NOT NULL THEN
                p_new_rec.parent_system_id := get_csr.new_parent_system_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.parent_system_id := get_csr.old_parent_system_id;
             END IF;

             IF get_csr.new_ship_to_contact_id IS NOT NULL THEN
                p_new_rec.ship_to_contact_id := get_csr.new_ship_to_contact_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.ship_to_contact_id := get_csr.old_ship_to_contact_id;
             END IF;

             IF get_csr.new_bill_to_contact_id IS NOT NULL THEN
                p_new_rec.bill_to_contact_id := get_csr.new_bill_to_contact_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.bill_to_contact_id := get_csr.old_bill_to_contact_id;
             END IF;

             IF get_csr.new_technical_contact_id IS NOT NULL THEN
                p_new_rec.technical_contact_id := get_csr.new_technical_contact_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.technical_contact_id := get_csr.old_technical_contact_id;
             END IF;

             IF get_csr.new_service_admin_contact_id IS NOT NULL THEN
                p_new_rec.service_admin_contact_id := get_csr.new_service_admin_contact_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                 p_new_rec.service_admin_contact_id := get_csr.old_service_admin_contact_id;
             END IF;

             IF get_csr.new_ship_to_site_use_id IS NOT NULL THEN
                p_new_rec.ship_to_site_use_id := get_csr.new_ship_to_site_use_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.ship_to_site_use_id := get_csr.old_ship_to_site_use_id;
             END IF;

             IF get_csr.new_install_site_use_id IS NOT NULL THEN
                p_new_rec.install_site_use_id := get_csr.new_install_site_use_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.install_site_use_id := get_csr.old_install_site_use_id;
             END IF;

             IF get_csr.new_bill_to_site_use_id IS NOT NULL THEN
                p_new_rec.bill_to_site_use_id := get_csr.new_bill_to_site_use_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.bill_to_site_use_id := get_csr.old_bill_to_site_use_id;
             END IF;

             IF get_csr.new_coterminate_day_month IS NOT NULL THEN
                p_new_rec.coterminate_day_month := get_csr.new_coterminate_day_month;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.coterminate_day_month := get_csr.old_coterminate_day_month;
             END IF;

             IF get_csr.new_start_date_active IS NOT NULL THEN
                p_new_rec.start_date_active := get_csr.new_start_date_active;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.start_date_active := get_csr.old_start_date_active;
             END IF;

             IF get_csr.new_end_date_active IS NOT NULL THEN
                p_new_rec.end_date_active := get_csr.new_end_date_active;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.end_date_active := get_csr.old_end_date_active;
             END IF;

             IF get_csr.new_autocreated_from_system IS NOT NULL THEN
                p_new_rec.autocreated_from_system_id := get_csr.new_autocreated_from_system;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.autocreated_from_system_id := get_csr.old_autocreated_from_system;
             END IF;

             IF get_csr.new_config_system_type IS NOT NULL THEN
                p_new_rec.config_system_type := get_csr.new_config_system_type;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.config_system_type := get_csr.old_config_system_type;
             END IF;

             IF get_csr.new_context IS NOT NULL THEN
                p_new_rec.context := get_csr.new_context;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.context := get_csr.old_context;
             END IF;

             IF get_csr.new_attribute1 IS NOT NULL THEN
                p_new_rec.attribute1 := get_csr.new_attribute1;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute1 := get_csr.old_attribute1;
             END IF;

             IF get_csr.new_attribute2 IS NOT NULL THEN
                p_new_rec.attribute2 := get_csr.new_attribute2;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute2 := get_csr.old_attribute2;
             END IF;

             IF get_csr.new_attribute3 IS NOT NULL THEN
                p_new_rec.attribute3 := get_csr.new_attribute3;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute3 := get_csr.old_attribute3;
             END IF;

             IF get_csr.new_attribute4 IS NOT NULL THEN
                p_new_rec.attribute4 := get_csr.new_attribute4;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute4 := get_csr.old_attribute4;
             END IF;

             IF get_csr.new_attribute5 IS NOT NULL THEN
                p_new_rec.attribute5 := get_csr.new_attribute5;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute5 := get_csr.old_attribute5;
             END IF;

             IF get_csr.new_attribute6 IS NOT NULL THEN
                p_new_rec.attribute6 := get_csr.new_attribute6;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute6 := get_csr.old_attribute6;
             END IF;

             IF get_csr.new_attribute7 IS NOT NULL THEN
                p_new_rec.attribute7 := get_csr.new_attribute7;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute7 := get_csr.old_attribute7;
             END IF;

             IF get_csr.new_attribute8 IS NOT NULL THEN
                p_new_rec.attribute8 := get_csr.new_attribute8;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute8 := get_csr.old_attribute8;
             END IF;

             IF  get_csr.new_attribute9 IS NOT NULL THEN
                p_new_rec.attribute9 := get_csr.new_attribute9;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute9 := get_csr.old_attribute9;
             END IF;

             IF get_csr.new_attribute10 IS NOT NULL THEN
                p_new_rec.attribute10 := get_csr.new_attribute10;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute10 := get_csr.old_attribute10;
             END IF;

             IF get_csr.new_attribute11 IS NOT NULL THEN
                p_new_rec.attribute11 := get_csr.new_attribute11;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute11 := get_csr.old_attribute11;
             END IF;

             IF  get_csr.new_attribute12 IS NOT NULL THEN
                p_new_rec.attribute12 := get_csr.new_attribute12;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute12 := get_csr.old_attribute12;
             END IF;

             IF get_csr.new_attribute13 IS NOT NULL THEN
                p_new_rec.attribute13 := get_csr.new_attribute13;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute13 := get_csr.old_attribute13;
             END IF;

             IF  get_csr.new_attribute14 IS NOT NULL THEN
                p_new_rec.attribute14 := get_csr.new_attribute14;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute14 := get_csr.old_attribute14;
             END IF;

             IF  get_csr.new_attribute15 IS NOT NULL THEN
                p_new_rec.attribute15 := get_csr.new_attribute15;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute15 := get_csr.old_attribute15;
             END IF;

             IF  get_csr.new_operating_unit_id IS NOT NULL THEN
                p_new_rec.operating_unit_id := get_csr.new_operating_unit_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.operating_unit_id := get_csr.old_operating_unit_id;
             END IF;

          END LOOP;
             IF  p_new_rec.customer_id = fnd_api.g_miss_num THEN
                 p_new_rec.customer_id := NULL;
             END IF;

             IF p_new_rec.system_type_code = fnd_api.g_miss_char THEN
                p_new_rec.system_type_code := NULL;
             END IF;

             IF p_new_rec.system_number = fnd_api.g_miss_char THEN
                p_new_rec.system_number := NULL;
             END IF;

             IF p_new_rec.parent_system_id = fnd_api.g_miss_num THEN
                p_new_rec.parent_system_id := NULL;
             END IF;

             IF p_new_rec.ship_to_contact_id = fnd_api.g_miss_num THEN
                p_new_rec.ship_to_contact_id := NULL;
             END IF;

             IF p_new_rec.bill_to_contact_id = fnd_api.g_miss_num THEN
                p_new_rec.bill_to_contact_id := NULL;
             END IF;

             IF p_new_rec.technical_contact_id = fnd_api.g_miss_num THEN
                p_new_rec.technical_contact_id := NULL;
             END IF;

             IF p_new_rec.service_admin_contact_id = fnd_api.g_miss_num THEN
                p_new_rec.service_admin_contact_id := NULL;
             END IF;

             IF p_new_rec.ship_to_site_use_id = fnd_api.g_miss_num THEN
                p_new_rec.ship_to_site_use_id := NULL;
             END IF;

             IF p_new_rec.bill_to_site_use_id = fnd_api.g_miss_num THEN
                p_new_rec.bill_to_site_use_id := NULL;
             END IF;

             IF p_new_rec.install_site_use_id = fnd_api.g_miss_num THEN
                p_new_rec.install_site_use_id := NULL;
             END IF;

             IF p_new_rec.coterminate_day_month = fnd_api.g_miss_char THEN
                p_new_rec.coterminate_day_month := NULL;
             END IF;

             IF p_new_rec.autocreated_from_system_id = fnd_api.g_miss_num THEN
                p_new_rec.autocreated_from_system_id := NULL;
             END IF;

             IF p_new_rec.config_system_type = fnd_api.g_miss_char THEN
                p_new_rec.config_system_type := NULL;
             END IF;

             IF p_new_rec.start_date_active = fnd_api.g_miss_date THEN
                 p_new_rec.start_date_active := NULL;
             END IF;

             IF p_new_rec.end_date_active = fnd_api.g_miss_date THEN
                p_new_rec.end_date_active := NULL;
             END IF;

             IF p_new_rec.context = fnd_api.g_miss_char THEN
                p_new_rec.context := NULL;
             END IF;

             IF p_new_rec.attribute1 = fnd_api.g_miss_char THEN
                p_new_rec.attribute1 := NULL;
             END IF;

             IF p_new_rec.attribute2 = fnd_api.g_miss_char THEN
                p_new_rec.attribute2 := NULL;
             END IF;

             IF p_new_rec.attribute3 = fnd_api.g_miss_char THEN
                p_new_rec.attribute3 := NULL;
             END IF;

             IF p_new_rec.attribute4 = fnd_api.g_miss_char THEN
                p_new_rec.attribute4 := NULL;
             END IF;

             IF p_new_rec.attribute5 = fnd_api.g_miss_char THEN
                p_new_rec.attribute5 := NULL;
             END IF;

             IF p_new_rec.attribute6 = fnd_api.g_miss_char THEN
                p_new_rec.attribute6 := NULL;
             END IF;

             IF p_new_rec.attribute7 =fnd_api.g_miss_char THEN
                p_new_rec.attribute7 := NULL;
             END IF;

             IF p_new_rec.attribute8 = fnd_api.g_miss_char THEN
                p_new_rec.attribute8 := NULL;
             END IF;

             IF p_new_rec.attribute9 = fnd_api.g_miss_char THEN
                p_new_rec.attribute9 := NULL;
             END IF;

             IF p_new_rec.attribute10 = fnd_api.g_miss_char THEN
                p_new_rec.attribute10 := NULL;
             END IF;

             IF p_new_rec.attribute11 = fnd_api.g_miss_char THEN
                p_new_rec.attribute11 := NULL;
             END IF;

             IF p_new_rec.attribute12 = fnd_api.g_miss_char THEN
                p_new_rec.attribute12 := NULL;
             END IF;

             IF p_new_rec.attribute13 = fnd_api.g_miss_char THEN
                p_new_rec.attribute13 := NULL;
             END IF;

             IF p_new_rec.attribute14 =fnd_api.g_miss_char THEN
                p_new_rec.attribute14 := NULL;
             END IF;

             IF p_new_rec.attribute15 = fnd_api.g_miss_char THEN
                p_new_rec.attribute15 := NULL;
             END IF;

             IF p_new_rec.operating_unit_id = fnd_api.g_miss_num THEN
                p_new_rec.operating_unit_id := NULL;
             END IF;

           p_flag :='ADD';
        END IF;

END;



PROCEDURE get_systems
 (
     p_api_version               IN  NUMBER  ,
     p_commit                    IN  VARCHAR2,
     p_init_msg_list             IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     p_system_query_rec          IN  csi_datastructures_pub.system_query_rec,
     p_time_stamp                IN  DATE    ,
     p_active_systems_only       IN  VARCHAR2,
     x_systems_tbl               OUT NOCOPY csi_datastructures_pub.systems_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER  ,
     x_msg_data                  OUT NOCOPY VARCHAR2
 )
 IS

l_api_name                 CONSTANT VARCHAR2(30)    := 'get_systems';
l_api_version              CONSTANT NUMBER          := 1.0;
l_return_status_full                VARCHAR2(1);
l_crit_systems_rec                  csi_datastructures_pub.system_query_rec := p_system_query_rec;
l_systems_where                     VARCHAR2(2000)  := '';
l_cur_get_systems                   NUMBER;
l_select_cl                         VARCHAR2(2000)  := '';
l_def_systems_rec                   csi_datastructures_pub.system_rec;
l_ignore                            NUMBER;
l_return_tot_count                  VARCHAR2(1)     := fnd_api.g_false;
l_returned_rec_count                NUMBER          := 0;
l_sys_rec                           csi_datastructures_pub.system_rec;
l_tot_rec_count                     NUMBER          := 0;
l_start_rec_prt                     NUMBER          :=1;
l_rec_requested                     NUMBER          :=1000000;
l_new_rec                           csi_datastructures_pub.system_rec;
l_flag                              VARCHAR2(4);
l_active_systems_only               VARCHAR2(1):= p_active_systems_only;
l_debug_level                       NUMBER;
l_systems_tbl                       csi_datastructures_pub.systems_tbl;
l_sys_count                         NUMBER := 0;
l_last_purge_date                   DATE;

BEGIN

      -- standard start of api savepoint
    --  SAVEPOINT get_systems_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;




      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        IF (l_debug_level > 0) THEN
          csi_gen_utility_pvt.put_line( 'get_system');
        END IF;

        IF (l_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_Commit                  ||'-'||
                                p_Init_Msg_list           ||'-'||
                                p_Validation_level        ||'-'||
                                p_time_stamp              ||'-'||
                                p_active_systems_only
                                );
            csi_gen_utility_pvt.dump_sys_query_rec(p_system_query_rec);
        END IF;

      IF
      ( ((p_system_query_rec.system_id IS NULL)         OR (p_system_query_rec.system_id = fnd_api.g_miss_num))
    AND ((p_system_query_rec.system_type_code IS NULL)  OR (p_system_query_rec.system_type_code = fnd_api.g_miss_char))
    AND ((p_system_query_rec.system_number IS NULL)     OR (p_system_query_rec.system_number  = fnd_api.g_miss_char))
      )
      THEN
       fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       RAISE fnd_api.g_exc_error;
      END IF;

      gen_select(l_crit_systems_rec,l_select_cl);


      gen_systems_where(l_crit_systems_rec,l_active_systems_only, l_systems_where);
          IF dbms_sql.is_open(l_cur_get_systems) THEN
          dbms_sql.close_CURSOR(l_cur_get_systems);
          END IF;

       l_cur_get_systems := dbms_sql.open_CURSOR;

       dbms_sql.parse(l_cur_get_systems, l_select_cl||l_systems_where , dbms_sql.native);

       bind(l_crit_systems_rec, l_cur_get_systems);

       define_columns(l_def_systems_rec, l_cur_get_systems);

       l_ignore := dbms_sql.execute(l_cur_get_systems);
     --
     -- Get the last purge date from csi_item_instances table
     --
     BEGIN
       SELECT last_purge_date
       INTO   l_last_purge_date
       FROM   CSI_ITEM_INSTANCES
       WHERE  rownum < 2;
     EXCEPTION
       WHEN no_data_found THEN
         NULL;
       WHEN others THEN
         NULL;
     END;
     --
     LOOP
     IF((dbms_sql.fetch_rows(l_cur_get_systems)>0) AND ( (l_returned_rec_count<l_rec_requested) OR (l_rec_requested=fnd_api.g_miss_num)))
      THEN

             get_column_values(l_cur_get_systems, l_sys_rec);

              l_tot_rec_count := l_tot_rec_count + 1 ;

              IF  (l_returned_rec_count < l_rec_requested) THEN
                   l_returned_rec_count := l_returned_rec_count + 1;

                   IF ((p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE))
                   THEN
                       IF ((l_last_purge_date IS NOT NULL) AND (p_time_stamp <= l_last_purge_date))
                       THEN
                           csi_gen_utility_pvt.put_line('Warning! History for this entity has already been purged for the datetime stamp passed. ' ||
                           'Please provide a valid datetime stamp.');
                           FND_MESSAGE.Set_Name('CSI', 'CSI_API_HIST_AFTER_PURGE_REQ');
                           FND_MSG_PUB.ADD;
                       ELSE
                           get_history( p_sys_rec    => l_sys_rec
                                       ,p_new_rec    => l_new_rec
                                       ,p_flag       => l_flag
                                       ,p_time_stamp => p_time_stamp);
                               IF l_flag='ADD' THEN
                                  l_systems_tbl(l_returned_rec_count) :=l_new_rec;--l_sys_rec;
                               END IF;
                       END IF;
                    ELSE
                       l_systems_tbl(l_returned_rec_count) :=l_sys_rec;
                    END IF;
              END IF;
      ELSE
          EXIT;
      END IF;
      END LOOP;
      --
      IF l_active_systems_only = 'T' THEN
         IF l_systems_tbl.count > 0 THEN
            FOR sys_row IN l_systems_tbl.FIRST .. l_systems_tbl.LAST
            LOOP
               IF l_systems_tbl.EXISTS(sys_row) THEN
                  IF l_systems_tbl(sys_row).end_date_active IS NULL OR
                     l_systems_tbl(sys_row).end_date_active >= SYSDATE THEN
                     l_sys_count := l_sys_count + 1;
                     x_systems_tbl(l_sys_count) := l_systems_tbl(sys_row);
                  END IF;
               END IF;
            END LOOP;
         END IF;
      ELSE
         x_systems_tbl := l_systems_tbl;
      END IF;
      -- END of api body
      --
     dbms_sql.close_cursor(l_cur_get_systems);

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
          --     ROLLBACK TO get_systems_pvt;
               x_return_status := fnd_api.g_ret_sts_error ;
               fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
          --      ROLLBACK TO get_systems_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                         (p_count => x_msg_count ,
                          p_data => x_msg_data
                         );

          WHEN OTHERS THEN
           --     ROLLBACK TO get_systems_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                         (p_count => x_msg_count ,
                          p_data => x_msg_data
                         );

END get_systems;


/* ----------------------------------------------------------------------------------------------- */
/* This Procedure(during creation/updation)is used to check for Unique system_name for a Customer  */
/*  and System_Number.IF found then raise an error else success                                    */
/* ----------------------------------------------------------------------------------------------- */
PROCEDURE Check_Unique(
             p_System_id     IN     NUMBER  ,
             p_Name          IN     VARCHAR2,
             p_Customer_ID   IN     NUMBER  ,
             p_System_number IN     VARCHAR2,
             x_return_status OUT NOCOPY    VARCHAR2,
             x_msg_count     OUT NOCOPY    NUMBER  ,
             x_msg_data      OUT NOCOPY    VARCHAR2) IS
    CURSOR dup_cur IS
      SELECT 'x'
      FROM   csi_systems_vl
      WHERE  name = p_Name
      AND    customer_id = p_Customer_ID
    --AND    system_number = nvl(p_System_number,system_number)
      AND   (system_number IS NULL OR
             system_number = p_System_number)
      AND   (p_System_id IS NULL OR
                 System_id <> p_System_id);
    l_dummy VARCHAR2(1);
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
    OPEN dup_cur;
    FETCH dup_cur INTO l_dummy;
    IF (dup_cur%FOUND) THEN
      FND_MESSAGE.SET_NAME('CSI', 'CSI_SYSTEM_DUP_NAME');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    CLOSE dup_cur;

  EXCEPTION
      WHEN OTHERS THEN
         NULL;
  END Check_Unique;



/* ----------------------------------------------------------------------------------------------- */
/* This procedure(during creation)is used to check if the received subject is already an object    */
/*  if found then raise and error else success                                                     */
/*                      a                                                                          */
/*                     / \                                                                         */
/*                    b   c                                                                        */
/*                    / \                                                                          */
/*                   d   a -> not allowed                                                          */
/* ----------------------------------------------------------------------------------------------- */

 PROCEDURE check_parent_child_constraint(x_system_id            IN  NUMBER,
                                         x_parent_system_id     IN  NUMBER,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_msg_count            OUT NOCOPY NUMBER,
                                         x_msg_data             OUT NOCOPY VARCHAR2) IS

 CURSOR par_chld_csr IS
          SELECT 'x'
          FROM   csi_systems_b
          WHERE  system_id = x_parent_system_id
          START WITH parent_system_id = x_system_id
          CONNECT BY parent_system_id = prior system_id;
 l_dummy VARCHAR2(1);

BEGIN
    --
    -- check to make sure that parent system exists and it doesn't have
    -- a parent of its own
    --
x_return_status := fnd_api.g_ret_sts_success;

 IF x_system_id <> x_parent_system_id THEN
   OPEN  par_chld_csr;
   FETCH par_chld_csr INTO l_dummy;
     IF (par_chld_csr%found) THEN
         --CLOSE par_chld_csr;
         fnd_message.set_name('CSI','CSI_CHILD_PARENT_REL_LOOP');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
     END IF;
   CLOSE par_chld_csr;

    ELSE
      fnd_message.set_name('CSI', 'CSI_PARENT_CHILD_INVALID');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
 END IF;

END check_parent_child_constraint;


PROCEDURE validate_history(p_old_systems_rec IN   csi_datastructures_pub.system_rec,
                           p_new_systems_rec IN   csi_datastructures_pub.system_rec,
                           p_transaction_id  IN   NUMBER,
                           p_flag            IN   VARCHAR2,
                           p_sysdate         IN   DATE,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2)
IS
l_old_systems_rec   csi_datastructures_pub.system_rec :=p_old_systems_rec;
l_new_systems_rec   csi_datastructures_pub.system_rec :=p_new_systems_rec;
l_transaction_id        NUMBER := p_transaction_id;
l_full_dump             NUMBER;
l_systems_hist_rec     csi_datastructures_pub.system_history_rec;

CURSOR sys_hist_csr (p_sys_hist_id  NUMBER) IS
 SELECT  *
 FROM    csi_systems_h
 WHERE   csi_systems_h.system_history_id = p_sys_hist_id
 FOR UPDATE OF object_version_number;
l_sys_hist_csr   sys_hist_csr%ROWTYPE;
l_sys_hist_id    NUMBER;

BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
         csi_gen_utility_pvt.populate_install_param_rec;
      END IF;
      --
      l_full_dump := csi_datastructures_pub.g_install_param_rec.history_full_dump_frequency;
      --
      IF l_full_dump IS NULL THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_flag = 'EXPIRE' THEN
         l_new_systems_rec.end_date_active := p_sysdate;
      END IF;
     -- Start of modifications for Bug#2547034 on 09/20/02 - rtalluri

      BEGIN
        SELECT  system_history_id
        INTO    l_sys_hist_id
        FROM    csi_systems_h h
        WHERE   h.transaction_id = p_transaction_id
        AND     h.system_id = p_old_systems_rec.system_id;

        OPEN   sys_hist_csr(l_sys_hist_id);
        FETCH  sys_hist_csr INTO l_sys_hist_csr ;
        CLOSE  sys_hist_csr;

        IF l_sys_hist_csr.full_dump_flag = 'Y'
        THEN
         csi_systems_h_pkg.update_row(
                     p_system_history_id             => l_sys_hist_id,
                     p_system_id                     => fnd_api.g_miss_num,
                     p_transaction_id                => fnd_api.g_miss_num,
                     p_old_customer_id               => fnd_api.g_miss_num,
                     p_new_customer_id               => l_new_systems_rec.customer_id,
                     p_old_system_type_code          => fnd_api.g_miss_char,
                     p_new_system_type_code          => l_new_systems_rec.system_type_code,
                     p_old_system_number             => fnd_api.g_miss_char,
                     p_new_system_number             => l_new_systems_rec.system_number,
                     p_old_parent_system_id          => fnd_api.g_miss_num,
                     p_new_parent_system_id          => l_new_systems_rec.parent_system_id,
                     p_old_ship_to_contact_id        => fnd_api.g_miss_num,
                     p_new_ship_to_contact_id        => l_new_systems_rec.ship_to_contact_id,
                     p_old_bill_to_contact_id        => fnd_api.g_miss_num,
                     p_new_bill_to_contact_id        => l_new_systems_rec.bill_to_contact_id,
                     p_old_technical_contact_id      => fnd_api.g_miss_num,
                     p_new_technical_contact_id      => l_new_systems_rec.technical_contact_id,
                     p_old_service_admin_contact_id  => fnd_api.g_miss_num,
                     p_new_service_admin_contact_id  => l_new_systems_rec.service_admin_contact_id,
                     p_old_ship_to_site_use_id       => fnd_api.g_miss_num,
                     p_new_ship_to_site_use_id       => l_new_systems_rec.ship_to_site_use_id,
                     p_old_install_site_use_id       => fnd_api.g_miss_num,
                     p_new_install_site_use_id       => l_new_systems_rec.install_site_use_id,
                     p_old_bill_to_site_use_id       => fnd_api.g_miss_num,
                     p_new_bill_to_site_use_id       => l_new_systems_rec.bill_to_site_use_id,
                     p_old_coterminate_day_month     => fnd_api.g_miss_char,
                     p_new_coterminate_day_month     => l_new_systems_rec.coterminate_day_month,
                     p_old_start_date_active         => fnd_api.g_miss_date,
                     p_new_start_date_active         => l_new_systems_rec.start_date_active,
                     p_old_end_date_active           => fnd_api.g_miss_date,
                     p_new_end_date_active           => l_new_systems_rec.end_date_active,
                     p_old_autocreated_from_system   => fnd_api.g_miss_num,
                     p_new_autocreated_from_system   => l_new_systems_rec.autocreated_from_system_id,
                     p_old_config_system_type        => fnd_api.g_miss_char,
                     p_new_config_system_type        => l_new_systems_rec.config_system_type,
                     p_old_context                   => fnd_api.g_miss_char,
                     p_new_context                   => l_new_systems_rec.context,
                     p_old_attribute1                => fnd_api.g_miss_char,
                     p_new_attribute1                => l_new_systems_rec.attribute1,
                     p_old_attribute2                => fnd_api.g_miss_char,
                     p_new_attribute2                => l_new_systems_rec.attribute2,
                     p_old_attribute3                => fnd_api.g_miss_char,
                     p_new_attribute3                => l_new_systems_rec.attribute3,
                     p_old_attribute4                => fnd_api.g_miss_char,
                     p_new_attribute4                => l_new_systems_rec.attribute4,
                     p_old_attribute5                => fnd_api.g_miss_char,
                     p_new_attribute5                => l_new_systems_rec.attribute5,
                     p_old_attribute6                => fnd_api.g_miss_char,
                     p_new_attribute6                => l_new_systems_rec.attribute6,
                     p_old_attribute7                => fnd_api.g_miss_char,
                     p_new_attribute7                => l_new_systems_rec.attribute7,
                     p_old_attribute8                => fnd_api.g_miss_char,
                     p_new_attribute8                => l_new_systems_rec.attribute8,
                     p_old_attribute9                => fnd_api.g_miss_char,
                     p_new_attribute9                => l_new_systems_rec.attribute9,
                     p_old_attribute10               => fnd_api.g_miss_char,
                     p_new_attribute10               => l_new_systems_rec.attribute10,
                     p_old_attribute11               => fnd_api.g_miss_char,
                     p_new_attribute11               => l_new_systems_rec.attribute11,
                     p_old_attribute12               => fnd_api.g_miss_char,
                     p_new_attribute12               => l_new_systems_rec.attribute12,
                     p_old_attribute13               => fnd_api.g_miss_char,
                     p_new_attribute13               => l_new_systems_rec.attribute13,
                     p_old_attribute14               => fnd_api.g_miss_char,
                     p_new_attribute14               => l_new_systems_rec.attribute14,
                     p_old_attribute15               => fnd_api.g_miss_char,
                     p_new_attribute15               => l_new_systems_rec.attribute15,
                     p_full_dump_flag                => fnd_api.g_miss_char,
                     p_created_by                    => fnd_api.g_miss_num, -- fnd_global.user_id,
                     p_creation_date                 => fnd_api.g_miss_date,
                     p_last_updated_by               => fnd_global.user_id,
                     p_last_update_date              => SYSDATE,
                     p_last_update_login             => fnd_global.conc_login_id,
                     p_object_version_number         => fnd_api.g_miss_num,
                     p_old_name                      => fnd_api.g_miss_char,
                     p_new_name                      => l_new_systems_rec.name,
                     p_old_description               => fnd_api.g_miss_char,
                     p_new_description               => l_new_systems_rec.description,
                     p_old_operating_unit_id         => fnd_api.g_miss_num,
                     p_new_operating_unit_id         => l_new_systems_rec.operating_unit_id
                      );

        ELSE

             IF    ( l_sys_hist_csr.old_customer_id IS NULL
                AND  l_sys_hist_csr.new_customer_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.customer_id = l_old_systems_rec.customer_id )
                      OR ( l_new_systems_rec.customer_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_customer_id := NULL;
                           l_sys_hist_csr.new_customer_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_customer_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_customer_id := l_new_systems_rec.customer_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_customer_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_customer_id := l_new_systems_rec.customer_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_system_type_code IS NULL
                AND  l_sys_hist_csr.new_system_type_code IS NULL ) THEN
                     IF  ( l_new_systems_rec.system_type_code = l_old_systems_rec.system_type_code )
                      OR ( l_new_systems_rec.system_type_code = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_system_type_code := NULL;
                           l_sys_hist_csr.new_system_type_code := NULL;
                     ELSE
                           l_sys_hist_csr.old_system_type_code := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_system_type_code := l_new_systems_rec.system_type_code;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_system_type_code := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_system_type_code := l_new_systems_rec.system_type_code;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_system_number IS NULL
                AND  l_sys_hist_csr.new_system_number IS NULL ) THEN
                     IF  ( l_new_systems_rec.system_number = l_old_systems_rec.system_number )
                      OR ( l_new_systems_rec.system_number = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_system_number := NULL;
                           l_sys_hist_csr.new_system_number := NULL;
                     ELSE
                           l_sys_hist_csr.old_system_number := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_system_number := l_new_systems_rec.system_number;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_system_number := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_system_number := l_new_systems_rec.system_number;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_parent_system_id IS NULL
                AND  l_sys_hist_csr.new_parent_system_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.parent_system_id = l_old_systems_rec.parent_system_id )
                      OR ( l_new_systems_rec.parent_system_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_parent_system_id := NULL;
                           l_sys_hist_csr.new_parent_system_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_parent_system_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_parent_system_id := l_new_systems_rec.parent_system_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_parent_system_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_parent_system_id := l_new_systems_rec.parent_system_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_ship_to_contact_id IS NULL
                AND  l_sys_hist_csr.new_ship_to_contact_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.ship_to_contact_id = l_old_systems_rec.ship_to_contact_id )
                      OR ( l_new_systems_rec.ship_to_contact_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_ship_to_contact_id := NULL;
                           l_sys_hist_csr.new_ship_to_contact_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_ship_to_contact_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_ship_to_contact_id := l_new_systems_rec.ship_to_contact_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_ship_to_contact_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_ship_to_contact_id := l_new_systems_rec.ship_to_contact_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_bill_to_contact_id IS NULL
                AND  l_sys_hist_csr.new_bill_to_contact_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.bill_to_contact_id = l_old_systems_rec.bill_to_contact_id )
                      OR ( l_new_systems_rec.bill_to_contact_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_bill_to_contact_id := NULL;
                           l_sys_hist_csr.new_bill_to_contact_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_bill_to_contact_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_bill_to_contact_id := l_new_systems_rec.bill_to_contact_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_bill_to_contact_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_bill_to_contact_id := l_new_systems_rec.bill_to_contact_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_technical_contact_id IS NULL
                AND  l_sys_hist_csr.new_technical_contact_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.technical_contact_id = l_old_systems_rec.technical_contact_id )
                      OR ( l_new_systems_rec.technical_contact_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_technical_contact_id := NULL;
                           l_sys_hist_csr.new_technical_contact_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_technical_contact_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_technical_contact_id := l_new_systems_rec.technical_contact_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_technical_contact_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_technical_contact_id := l_new_systems_rec.technical_contact_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_service_admin_contact_id IS NULL
                AND  l_sys_hist_csr.new_service_admin_contact_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.service_admin_contact_id = l_old_systems_rec.service_admin_contact_id )
                      OR ( l_new_systems_rec.service_admin_contact_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_service_admin_contact_id := NULL;
                           l_sys_hist_csr.new_service_admin_contact_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_service_admin_contact_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_service_admin_contact_id := l_new_systems_rec.service_admin_contact_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_service_admin_contact_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_service_admin_contact_id := l_new_systems_rec.service_admin_contact_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_ship_to_site_use_id IS NULL
                AND  l_sys_hist_csr.new_ship_to_site_use_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.ship_to_site_use_id = l_old_systems_rec.ship_to_site_use_id )
                      OR ( l_new_systems_rec.ship_to_site_use_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_ship_to_site_use_id := NULL;
                           l_sys_hist_csr.new_ship_to_site_use_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_ship_to_site_use_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_ship_to_site_use_id := l_new_systems_rec.ship_to_site_use_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_ship_to_site_use_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_ship_to_site_use_id := l_new_systems_rec.ship_to_site_use_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_bill_to_site_use_id IS NULL
                AND  l_sys_hist_csr.new_bill_to_site_use_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.bill_to_site_use_id = l_old_systems_rec.bill_to_site_use_id )
                      OR ( l_new_systems_rec.bill_to_site_use_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_bill_to_site_use_id := NULL;
                           l_sys_hist_csr.new_bill_to_site_use_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_bill_to_site_use_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_bill_to_site_use_id := l_new_systems_rec.bill_to_site_use_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_bill_to_site_use_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_bill_to_site_use_id := l_new_systems_rec.bill_to_site_use_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_install_site_use_id IS NULL
                AND  l_sys_hist_csr.new_install_site_use_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.install_site_use_id = l_old_systems_rec.install_site_use_id )
                      OR ( l_new_systems_rec.install_site_use_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_install_site_use_id := NULL;
                           l_sys_hist_csr.new_install_site_use_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_install_site_use_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_install_site_use_id := l_new_systems_rec.install_site_use_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_install_site_use_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_install_site_use_id := l_new_systems_rec.install_site_use_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_coterminate_day_month IS NULL
                AND  l_sys_hist_csr.new_coterminate_day_month IS NULL ) THEN
                     IF  ( l_new_systems_rec.coterminate_day_month = l_old_systems_rec.coterminate_day_month )
                      OR ( l_new_systems_rec.coterminate_day_month = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_coterminate_day_month := NULL;
                           l_sys_hist_csr.new_coterminate_day_month := NULL;
                     ELSE
                           l_sys_hist_csr.old_coterminate_day_month := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_coterminate_day_month := l_new_systems_rec.coterminate_day_month;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_coterminate_day_month := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_coterminate_day_month := l_new_systems_rec.coterminate_day_month;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_autocreated_from_system IS NULL
                AND  l_sys_hist_csr.new_autocreated_from_system IS NULL ) THEN
                     IF  ( l_new_systems_rec.autocreated_from_system_id = l_old_systems_rec.autocreated_from_system_id )
                      OR ( l_new_systems_rec.autocreated_from_system_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_autocreated_from_system := NULL;
                           l_sys_hist_csr.new_autocreated_from_system := NULL;
                     ELSE
                           l_sys_hist_csr.old_autocreated_from_system := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_autocreated_from_system := l_new_systems_rec.autocreated_from_system_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_autocreated_from_system := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_autocreated_from_system := l_new_systems_rec.autocreated_from_system_id;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_config_system_type IS NULL
                AND  l_sys_hist_csr.new_config_system_type IS NULL ) THEN
                     IF  ( l_new_systems_rec.config_system_type = l_old_systems_rec.config_system_type )
                      OR ( l_new_systems_rec.config_system_type = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_config_system_type := NULL;
                           l_sys_hist_csr.new_config_system_type := NULL;
                     ELSE
                           l_sys_hist_csr.old_config_system_type := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_config_system_type := l_new_systems_rec.config_system_type;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_config_system_type := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_config_system_type := l_new_systems_rec.config_system_type;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_start_date_active IS NULL
                AND  l_sys_hist_csr.new_start_date_active IS NULL ) THEN
                     IF  ( l_new_systems_rec.start_date_active = l_old_systems_rec.start_date_active )
                      OR ( l_new_systems_rec.start_date_active = fnd_api.g_miss_date ) THEN
                           l_sys_hist_csr.old_start_date_active := NULL;
                           l_sys_hist_csr.new_start_date_active := NULL;
                     ELSE
                           l_sys_hist_csr.old_start_date_active := fnd_api.g_miss_date;
                           l_sys_hist_csr.new_start_date_active := l_new_systems_rec.start_date_active;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_start_date_active := fnd_api.g_miss_date;
                     l_sys_hist_csr.new_start_date_active := l_new_systems_rec.start_date_active;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_end_date_active IS NULL
                AND  l_sys_hist_csr.new_end_date_active IS NULL ) THEN
                     IF  ( l_new_systems_rec.end_date_active = l_old_systems_rec.end_date_active )
                      OR ( l_new_systems_rec.end_date_active = fnd_api.g_miss_date ) THEN
                           l_sys_hist_csr.old_end_date_active := NULL;
                           l_sys_hist_csr.new_end_date_active := NULL;
                     ELSE
                           l_sys_hist_csr.old_end_date_active := fnd_api.g_miss_date;
                           l_sys_hist_csr.new_end_date_active := l_new_systems_rec.end_date_active;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_end_date_active := fnd_api.g_miss_date;
                     l_sys_hist_csr.new_end_date_active := l_new_systems_rec.end_date_active;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_context IS NULL
                AND  l_sys_hist_csr.new_context IS NULL ) THEN
                     IF  ( l_new_systems_rec.context = l_old_systems_rec.context )
                      OR ( l_new_systems_rec.context = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_context := NULL;
                           l_sys_hist_csr.new_context := NULL;
                     ELSE
                           l_sys_hist_csr.old_context := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_context := l_new_systems_rec.context;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_context := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_context := l_new_systems_rec.context;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute1 IS NULL
                AND  l_sys_hist_csr.new_attribute1 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute1 = l_old_systems_rec.attribute1 )
                      OR ( l_new_systems_rec.attribute1 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute1 := NULL;
                           l_sys_hist_csr.new_attribute1 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute1 := l_new_systems_rec.attribute1;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute1 := l_new_systems_rec.attribute1;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute2 IS NULL
                AND  l_sys_hist_csr.new_attribute2 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute2 = l_old_systems_rec.attribute2 )
                      OR ( l_new_systems_rec.attribute2 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute2 := NULL;
                           l_sys_hist_csr.new_attribute2 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute2 := l_new_systems_rec.attribute2;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute2 := l_new_systems_rec.attribute2;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute3 IS NULL
                AND  l_sys_hist_csr.new_attribute3 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute3 = l_old_systems_rec.attribute3 )
                      OR ( l_new_systems_rec.attribute3 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute3 := NULL;
                           l_sys_hist_csr.new_attribute3 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute3 := l_new_systems_rec.attribute3;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute3 := l_new_systems_rec.attribute3;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute4 IS NULL
                AND  l_sys_hist_csr.new_attribute4 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute4 = l_old_systems_rec.attribute4 )
                      OR ( l_new_systems_rec.attribute4 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute4 := NULL;
                           l_sys_hist_csr.new_attribute4 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute4 := l_new_systems_rec.attribute4;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute4 := l_new_systems_rec.attribute4;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute5 IS NULL
                AND  l_sys_hist_csr.new_attribute5 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute5 = l_old_systems_rec.attribute5 )
                      OR ( l_new_systems_rec.attribute5 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute5 := NULL;
                           l_sys_hist_csr.new_attribute5 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute5 := l_new_systems_rec.attribute5;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute5 := l_new_systems_rec.attribute5;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute6 IS NULL
                AND  l_sys_hist_csr.new_attribute6 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute6 = l_old_systems_rec.attribute6 )
                      OR ( l_new_systems_rec.attribute6 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute6 := NULL;
                           l_sys_hist_csr.new_attribute6 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute6 := l_new_systems_rec.attribute6;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute6 := l_new_systems_rec.attribute6;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute7 IS NULL
                AND  l_sys_hist_csr.new_attribute7 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute7 = l_old_systems_rec.attribute7 )
                      OR ( l_new_systems_rec.attribute7 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute7 := NULL;
                           l_sys_hist_csr.new_attribute7 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute7 := l_new_systems_rec.attribute7;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute7 := l_new_systems_rec.attribute7;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute8 IS NULL
                AND  l_sys_hist_csr.new_attribute8 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute8 = l_old_systems_rec.attribute8 )
                      OR ( l_new_systems_rec.attribute8 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute8 := NULL;
                           l_sys_hist_csr.new_attribute8 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute8 := l_new_systems_rec.attribute8;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute8 := l_new_systems_rec.attribute8;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute9 IS NULL
                AND  l_sys_hist_csr.new_attribute9 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute9 = l_old_systems_rec.attribute9 )
                      OR ( l_new_systems_rec.attribute9 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute9 := NULL;
                           l_sys_hist_csr.new_attribute9 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute9 := l_new_systems_rec.attribute9;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute9 := l_new_systems_rec.attribute9;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute10 IS NULL
                AND  l_sys_hist_csr.new_attribute10 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute10 = l_old_systems_rec.attribute10 )
                      OR ( l_new_systems_rec.attribute10 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute10 := NULL;
                           l_sys_hist_csr.new_attribute10 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute10 := l_new_systems_rec.attribute10;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute10 := l_new_systems_rec.attribute10;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute11 IS NULL
                AND  l_sys_hist_csr.new_attribute11 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute11 = l_old_systems_rec.attribute11 )
                      OR ( l_new_systems_rec.attribute11 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute11 := NULL;
                           l_sys_hist_csr.new_attribute11 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute11 := l_new_systems_rec.attribute11;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute11 := l_new_systems_rec.attribute11;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute12 IS NULL
                AND  l_sys_hist_csr.new_attribute12 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute12 = l_old_systems_rec.attribute12 )
                      OR ( l_new_systems_rec.attribute12 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute12 := NULL;
                           l_sys_hist_csr.new_attribute12 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute12 := l_new_systems_rec.attribute12;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute12 := l_new_systems_rec.attribute12;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute13 IS NULL
                AND  l_sys_hist_csr.new_attribute13 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute13 = l_old_systems_rec.attribute13 )
                      OR ( l_new_systems_rec.attribute13 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute13 := NULL;
                           l_sys_hist_csr.new_attribute13 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute13 := l_new_systems_rec.attribute13;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute13 := l_new_systems_rec.attribute13;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute14 IS NULL
                AND  l_sys_hist_csr.new_attribute14 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute14 = l_old_systems_rec.attribute14 )
                      OR ( l_new_systems_rec.attribute14 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute14 := NULL;
                           l_sys_hist_csr.new_attribute14 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute14 := l_new_systems_rec.attribute14;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute14 := l_new_systems_rec.attribute14;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_attribute15 IS NULL
                AND  l_sys_hist_csr.new_attribute15 IS NULL ) THEN
                     IF  ( l_new_systems_rec.attribute15 = l_old_systems_rec.attribute15 )
                      OR ( l_new_systems_rec.attribute15 = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_attribute15 := NULL;
                           l_sys_hist_csr.new_attribute15 := NULL;
                     ELSE
                           l_sys_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_attribute15 := l_new_systems_rec.attribute15;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_attribute15 := l_new_systems_rec.attribute15;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_name IS NULL
                AND  l_sys_hist_csr.new_name IS NULL ) THEN
                     IF  ( l_new_systems_rec.name = l_old_systems_rec.name )
                      OR ( l_new_systems_rec.name = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_name := NULL;
                           l_sys_hist_csr.new_name := NULL;
                     ELSE
                           l_sys_hist_csr.old_name := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_name := l_new_systems_rec.name;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_name := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_name := l_new_systems_rec.name;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_description IS NULL
                AND  l_sys_hist_csr.new_description IS NULL ) THEN
                     IF  ( l_new_systems_rec.description = l_old_systems_rec.description )
                      OR ( l_new_systems_rec.description = fnd_api.g_miss_char ) THEN
                           l_sys_hist_csr.old_description := NULL;
                           l_sys_hist_csr.new_description := NULL;
                     ELSE
                           l_sys_hist_csr.old_description := fnd_api.g_miss_char;
                           l_sys_hist_csr.new_description := l_new_systems_rec.description;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_description := fnd_api.g_miss_char;
                     l_sys_hist_csr.new_description := l_new_systems_rec.description;
             END IF;
          --
             IF    ( l_sys_hist_csr.old_operating_unit_id IS NULL
                AND  l_sys_hist_csr.new_operating_unit_id IS NULL ) THEN
                     IF  ( l_new_systems_rec.operating_unit_id = l_old_systems_rec.operating_unit_id )
                      OR ( l_new_systems_rec.operating_unit_id = fnd_api.g_miss_num ) THEN
                           l_sys_hist_csr.old_operating_unit_id := NULL;
                           l_sys_hist_csr.new_operating_unit_id := NULL;
                     ELSE
                           l_sys_hist_csr.old_operating_unit_id := fnd_api.g_miss_num;
                           l_sys_hist_csr.new_operating_unit_id := l_new_systems_rec.operating_unit_id;
                     END IF;
             ELSE
                     l_sys_hist_csr.old_operating_unit_id := fnd_api.g_miss_num;
                     l_sys_hist_csr.new_operating_unit_id := l_new_systems_rec.operating_unit_id;
             END IF;
          --

           csi_systems_h_pkg.update_row(
                     p_system_history_id             => l_sys_hist_id,
                     p_system_id                     => fnd_api.g_miss_num,
                     p_transaction_id                => fnd_api.g_miss_num,
                     p_old_customer_id               => l_sys_hist_csr.old_customer_id,
                     p_new_customer_id               => l_sys_hist_csr.new_customer_id,
                     p_old_system_type_code          => l_sys_hist_csr.old_system_type_code,
                     p_new_system_type_code          => l_sys_hist_csr.new_system_type_code,
                     p_old_system_number             => l_sys_hist_csr.old_system_number,
                     p_new_system_number             => l_sys_hist_csr.new_system_number,
                     p_old_parent_system_id          => l_sys_hist_csr.old_parent_system_id,
                     p_new_parent_system_id          => l_sys_hist_csr.new_parent_system_id,
                     p_old_ship_to_contact_id        => l_sys_hist_csr.old_ship_to_contact_id,
                     p_new_ship_to_contact_id        => l_sys_hist_csr.new_ship_to_contact_id,
                     p_old_bill_to_contact_id        => l_sys_hist_csr.old_bill_to_contact_id,
                     p_new_bill_to_contact_id        => l_sys_hist_csr.new_bill_to_contact_id,
                     p_old_technical_contact_id      => l_sys_hist_csr.old_technical_contact_id,
                     p_new_technical_contact_id      => l_sys_hist_csr.new_technical_contact_id,
                     p_old_service_admin_contact_id  => l_sys_hist_csr.old_service_admin_contact_id,
                     p_new_service_admin_contact_id  => l_sys_hist_csr.new_service_admin_contact_id,
                     p_old_ship_to_site_use_id       => l_sys_hist_csr.old_ship_to_site_use_id,
                     p_new_ship_to_site_use_id       => l_sys_hist_csr.new_ship_to_site_use_id,
                     p_old_install_site_use_id       => l_sys_hist_csr.old_install_site_use_id,
                     p_new_install_site_use_id       => l_sys_hist_csr.new_install_site_use_id,
                     p_old_bill_to_site_use_id       => l_sys_hist_csr.old_bill_to_site_use_id,
                     p_new_bill_to_site_use_id       => l_sys_hist_csr.new_bill_to_site_use_id,
                     p_old_coterminate_day_month     => l_sys_hist_csr.old_coterminate_day_month,
                     p_new_coterminate_day_month     => l_sys_hist_csr.new_coterminate_day_month,
                     p_old_start_date_active         => l_sys_hist_csr.old_start_date_active,
                     p_new_start_date_active         => l_sys_hist_csr.new_start_date_active,
                     p_old_end_date_active           => l_sys_hist_csr.old_end_date_active,
                     p_new_end_date_active           => l_sys_hist_csr.new_end_date_active,
                     p_old_autocreated_from_system   => l_sys_hist_csr.old_autocreated_from_system,
                     p_new_autocreated_from_system   => l_sys_hist_csr.new_autocreated_from_system,
                     p_old_config_system_type        => l_sys_hist_csr.old_config_system_type,
                     p_new_config_system_type        => l_sys_hist_csr.new_config_system_type,
                     p_old_context                   => l_sys_hist_csr.old_context,
                     p_new_context                   => l_sys_hist_csr.new_context,
                     p_old_attribute1                => l_sys_hist_csr.old_attribute1,
                     p_new_attribute1                => l_sys_hist_csr.new_attribute1,
                     p_old_attribute2                => l_sys_hist_csr.old_attribute2,
                     p_new_attribute2                => l_sys_hist_csr.new_attribute2,
                     p_old_attribute3                => l_sys_hist_csr.old_attribute3,
                     p_new_attribute3                => l_sys_hist_csr.new_attribute3,
                     p_old_attribute4                => l_sys_hist_csr.old_attribute4,
                     p_new_attribute4                => l_sys_hist_csr.new_attribute4,
                     p_old_attribute5                => l_sys_hist_csr.old_attribute5,
                     p_new_attribute5                => l_sys_hist_csr.new_attribute5,
                     p_old_attribute6                => l_sys_hist_csr.old_attribute6,
                     p_new_attribute6                => l_sys_hist_csr.new_attribute6,
                     p_old_attribute7                => l_sys_hist_csr.old_attribute7,
                     p_new_attribute7                => l_sys_hist_csr.new_attribute7,
                     p_old_attribute8                => l_sys_hist_csr.old_attribute8,
                     p_new_attribute8                => l_sys_hist_csr.new_attribute8,
                     p_old_attribute9                => l_sys_hist_csr.old_attribute9,
                     p_new_attribute9                => l_sys_hist_csr.new_attribute9,
                     p_old_attribute10               => l_sys_hist_csr.old_attribute10,
                     p_new_attribute10               => l_sys_hist_csr.new_attribute10,
                     p_old_attribute11               => l_sys_hist_csr.old_attribute11,
                     p_new_attribute11               => l_sys_hist_csr.new_attribute11,
                     p_old_attribute12               => l_sys_hist_csr.old_attribute12,
                     p_new_attribute12               => l_sys_hist_csr.new_attribute12,
                     p_old_attribute13               => l_sys_hist_csr.old_attribute13,
                     p_new_attribute13               => l_sys_hist_csr.new_attribute13,
                     p_old_attribute14               => l_sys_hist_csr.old_attribute14,
                     p_new_attribute14               => l_sys_hist_csr.new_attribute14,
                     p_old_attribute15               => l_sys_hist_csr.old_attribute15,
                     p_new_attribute15               => l_sys_hist_csr.new_attribute15,
                     p_full_dump_flag                => fnd_api.g_miss_char,
                     p_created_by                    => fnd_api.g_miss_num,
                     p_creation_date                 => fnd_api.g_miss_date,
                     p_last_updated_by               => fnd_global.user_id,
                     p_last_update_date              => SYSDATE,
                     p_last_update_login             => fnd_global.conc_login_id,
                     p_object_version_number         => fnd_api.g_miss_num,
                     p_old_name                      => l_sys_hist_csr.old_name,
                     p_new_name                      => l_sys_hist_csr.new_name,
                     p_old_description               => l_sys_hist_csr.old_description,
                     p_new_description               => l_sys_hist_csr.new_description,
                     p_old_operating_unit_id         => l_sys_hist_csr.old_operating_unit_id,
                     p_new_operating_unit_id         => l_sys_hist_csr.new_operating_unit_id
                      );
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN

          IF mod(l_old_systems_rec.object_version_number+1,l_full_dump)=0 THEN
                 csi_systems_h_pkg.insert_row(
                     px_system_history_id            => l_systems_hist_rec.system_history_id,
                     p_system_id                     => l_old_systems_rec.system_id,
                     p_transaction_id                => l_transaction_id,
                     p_old_customer_id               => l_old_systems_rec.customer_id,
                     p_new_customer_id               => l_new_systems_rec.customer_id,
                     p_old_system_type_code          => l_old_systems_rec.system_type_code,
                     p_new_system_type_code          => l_new_systems_rec.system_type_code,
                     p_old_system_number             => l_old_systems_rec.system_number,
                     p_new_system_number             => l_new_systems_rec.system_number,
                     p_old_parent_system_id          => l_old_systems_rec.parent_system_id,
                     p_new_parent_system_id          => l_new_systems_rec.parent_system_id,
                     p_old_ship_to_contact_id        => l_old_systems_rec.ship_to_contact_id,
                     p_new_ship_to_contact_id        => l_new_systems_rec.ship_to_contact_id,
                     p_old_bill_to_contact_id        => l_old_systems_rec.bill_to_contact_id,
                     p_new_bill_to_contact_id        => l_new_systems_rec.bill_to_contact_id,
                     p_old_technical_contact_id      => l_old_systems_rec.technical_contact_id,
                     p_new_technical_contact_id      => l_new_systems_rec.technical_contact_id,
                     p_old_service_admin_contact_id  => l_old_systems_rec.service_admin_contact_id,
                     p_new_service_admin_contact_id  => l_new_systems_rec.service_admin_contact_id,
                     p_old_ship_to_site_use_id       => l_old_systems_rec.ship_to_site_use_id,
                     p_new_ship_to_site_use_id       => l_new_systems_rec.ship_to_site_use_id,
                     p_old_install_site_use_id       => l_old_systems_rec.install_site_use_id,
                     p_new_install_site_use_id       => l_new_systems_rec.install_site_use_id,
                     p_old_bill_to_site_use_id       => l_old_systems_rec.bill_to_site_use_id,
                     p_new_bill_to_site_use_id       => l_new_systems_rec.bill_to_site_use_id,
                     p_old_coterminate_day_month     => l_old_systems_rec.coterminate_day_month,
                     p_new_coterminate_day_month     => l_new_systems_rec.coterminate_day_month,
                     p_old_start_date_active         => l_old_systems_rec.start_date_active,
                     p_new_start_date_active         => l_new_systems_rec.start_date_active,
                     p_old_end_date_active           => l_old_systems_rec.end_date_active,
                     p_new_end_date_active           => l_new_systems_rec.end_date_active,
                     p_old_autocreated_from_system   => l_old_systems_rec.autocreated_from_system_id,
                     p_new_autocreated_from_system   => l_new_systems_rec.autocreated_from_system_id,
                     p_old_config_system_type        => l_old_systems_rec.config_system_type,
                     p_new_config_system_type        => l_new_systems_rec.config_system_type,
                     p_old_context                   => l_old_systems_rec.context,
                     p_new_context                   => l_new_systems_rec.context,
                     p_old_attribute1                => l_old_systems_rec.attribute1,
                     p_new_attribute1                => l_new_systems_rec.attribute1,
                     p_old_attribute2                => l_old_systems_rec.attribute2,
                     p_new_attribute2                => l_new_systems_rec.attribute2,
                     p_old_attribute3                => l_old_systems_rec.attribute3,
                     p_new_attribute3                => l_new_systems_rec.attribute3,
                     p_old_attribute4                => l_old_systems_rec.attribute4,
                     p_new_attribute4                => l_new_systems_rec.attribute4,
                     p_old_attribute5                => l_old_systems_rec.attribute5,
                     p_new_attribute5                => l_new_systems_rec.attribute5,
                     p_old_attribute6                => l_old_systems_rec.attribute6,
                     p_new_attribute6                => l_new_systems_rec.attribute6,
                     p_old_attribute7                => l_old_systems_rec.attribute7,
                     p_new_attribute7                => l_new_systems_rec.attribute7,
                     p_old_attribute8                => l_old_systems_rec.attribute8,
                     p_new_attribute8                => l_new_systems_rec.attribute8,
                     p_old_attribute9                => l_old_systems_rec.attribute9,
                     p_new_attribute9                => l_new_systems_rec.attribute9,
                     p_old_attribute10               => l_old_systems_rec.attribute10,
                     p_new_attribute10               => l_new_systems_rec.attribute10,
                     p_old_attribute11               => l_old_systems_rec.attribute11,
                     p_new_attribute11               => l_new_systems_rec.attribute11,
                     p_old_attribute12               => l_old_systems_rec.attribute12,
                     p_new_attribute12               => l_new_systems_rec.attribute12,
                     p_old_attribute13               => l_old_systems_rec.attribute13,
                     p_new_attribute13               => l_new_systems_rec.attribute13,
                     p_old_attribute14               => l_old_systems_rec.attribute14,
                     p_new_attribute14               => l_new_systems_rec.attribute14,
                     p_old_attribute15               => l_old_systems_rec.attribute15,
                     p_new_attribute15               => l_new_systems_rec.attribute15,
                     p_full_dump_flag                => 'Y',
                     p_created_by                    => fnd_global.user_id,
                     p_creation_date                 => SYSDATE,
                     p_last_updated_by               => fnd_global.user_id,
                     p_last_update_date              => SYSDATE,
                     p_last_update_login             => fnd_global.conc_login_id,
                     p_object_version_number         => 1,
                     p_old_name                      => l_old_systems_rec.name,
                     p_new_name                      => l_new_systems_rec.name,
                     p_old_description               => l_old_systems_rec.description,
                     p_new_description               => l_new_systems_rec.description,
                     p_old_operating_unit_id         => l_old_systems_rec.operating_unit_id,
                     p_new_operating_unit_id         => l_new_systems_rec.operating_unit_id
                      );
  ELSE

          IF (l_new_systems_rec.customer_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.customer_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.customer_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_customer_id := NULL;
               l_systems_hist_rec.new_customer_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.customer_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.customer_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_customer_id := l_old_systems_rec.customer_id ;
               l_systems_hist_rec.new_customer_id := l_new_systems_rec.customer_id ;
          END IF;
          --
          IF (l_new_systems_rec.system_type_code = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.system_type_code,fnd_api.g_miss_char) = NVL(l_new_systems_rec.system_type_code,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_system_type_code := NULL;
               l_systems_hist_rec.new_system_type_code := NULL;
          ELSIF
              NVL(l_old_systems_rec.system_type_code,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.system_type_code,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_system_type_code := l_old_systems_rec.system_type_code ;
               l_systems_hist_rec.new_system_type_code := l_new_systems_rec.system_type_code ;
          END IF;
          --
          IF (l_new_systems_rec.system_number = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.system_number,fnd_api.g_miss_char) = NVL(l_new_systems_rec.system_number,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_system_number := NULL;
               l_systems_hist_rec.new_system_number := NULL;
          ELSIF
              NVL(l_old_systems_rec.system_number,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.system_number,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_system_number := l_old_systems_rec.system_number ;
               l_systems_hist_rec.new_system_number := l_new_systems_rec.system_number ;
          END IF;
          --
          IF (l_new_systems_rec.parent_system_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.parent_system_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.parent_system_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_parent_system_id := NULL;
               l_systems_hist_rec.new_parent_system_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.parent_system_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.parent_system_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_parent_system_id := l_old_systems_rec.parent_system_id ;
               l_systems_hist_rec.new_parent_system_id := l_new_systems_rec.parent_system_id ;
          END IF;
          --
          IF (l_new_systems_rec.ship_to_contact_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.ship_to_contact_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.ship_to_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_ship_to_contact_id := NULL;
               l_systems_hist_rec.new_ship_to_contact_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.ship_to_contact_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.ship_to_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_ship_to_contact_id := l_old_systems_rec.ship_to_contact_id ;
               l_systems_hist_rec.new_ship_to_contact_id := l_new_systems_rec.ship_to_contact_id ;
          END IF;
          --
          IF (l_new_systems_rec.bill_to_contact_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.bill_to_contact_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.bill_to_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_bill_to_contact_id := NULL;
               l_systems_hist_rec.new_bill_to_contact_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.bill_to_contact_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.bill_to_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_bill_to_contact_id := l_old_systems_rec.bill_to_contact_id ;
               l_systems_hist_rec.new_bill_to_contact_id := l_new_systems_rec.bill_to_contact_id ;
          END IF;
          --
          IF (l_new_systems_rec.technical_contact_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.technical_contact_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.technical_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_technical_contact_id := NULL;
               l_systems_hist_rec.new_technical_contact_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.technical_contact_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.technical_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_technical_contact_id := l_old_systems_rec.technical_contact_id ;
               l_systems_hist_rec.new_technical_contact_id := l_new_systems_rec.technical_contact_id ;
          END IF;
          --
          IF (l_new_systems_rec.service_admin_contact_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.service_admin_contact_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.service_admin_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_service_admin_contact_id := NULL;
               l_systems_hist_rec.new_service_admin_contact_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.service_admin_contact_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.service_admin_contact_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_service_admin_contact_id := l_old_systems_rec.service_admin_contact_id ;
               l_systems_hist_rec.new_service_admin_contact_id := l_new_systems_rec.service_admin_contact_id ;
          END IF;
          --
          IF (l_new_systems_rec.ship_to_site_use_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.ship_to_site_use_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.ship_to_site_use_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_ship_to_site_use_id := NULL;
               l_systems_hist_rec.new_ship_to_site_use_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.ship_to_site_use_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.ship_to_site_use_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_ship_to_site_use_id := l_old_systems_rec.ship_to_site_use_id ;
               l_systems_hist_rec.new_ship_to_site_use_id := l_new_systems_rec.ship_to_site_use_id ;
          END IF;
          --
          IF (l_new_systems_rec.bill_to_site_use_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.bill_to_site_use_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.bill_to_site_use_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_bill_to_site_use_id := NULL;
               l_systems_hist_rec.new_bill_to_site_use_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.bill_to_site_use_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.bill_to_site_use_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_bill_to_site_use_id := l_old_systems_rec.bill_to_site_use_id ;
               l_systems_hist_rec.new_bill_to_site_use_id := l_new_systems_rec.bill_to_site_use_id ;
          END IF;
          --
          IF (l_new_systems_rec.install_site_use_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.install_site_use_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.install_site_use_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_install_site_use_id := NULL;
               l_systems_hist_rec.new_install_site_use_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.install_site_use_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.install_site_use_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_install_site_use_id := l_old_systems_rec.install_site_use_id ;
               l_systems_hist_rec.new_install_site_use_id := l_new_systems_rec.install_site_use_id ;
          END IF;
          --
          IF (l_new_systems_rec.coterminate_day_month = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.coterminate_day_month,fnd_api.g_miss_char) = NVL(l_new_systems_rec.coterminate_day_month,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_coterminate_day_month := NULL;
               l_systems_hist_rec.new_coterminate_day_month := NULL;
          ELSIF
              NVL(l_old_systems_rec.coterminate_day_month,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.coterminate_day_month,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_coterminate_day_month := l_old_systems_rec.coterminate_day_month ;
               l_systems_hist_rec.new_coterminate_day_month := l_new_systems_rec.coterminate_day_month ;
          END IF;
          --
          IF (l_new_systems_rec.start_date_active = fnd_api.g_miss_date) OR
              NVL(l_old_systems_rec.start_date_active,fnd_api.g_miss_date) = NVL(l_new_systems_rec.start_date_active,fnd_api.g_miss_date) THEN
               l_systems_hist_rec.old_start_date_active := NULL;
               l_systems_hist_rec.new_start_date_active := NULL;
          ELSIF
              NVL(l_old_systems_rec.start_date_active,fnd_api.g_miss_date) <> NVL(l_new_systems_rec.start_date_active,fnd_api.g_miss_date) THEN
               l_systems_hist_rec.old_start_date_active := l_old_systems_rec.start_date_active ;
               l_systems_hist_rec.new_start_date_active := l_new_systems_rec.start_date_active ;
          END IF;
          --
          IF (l_new_systems_rec.end_date_active = fnd_api.g_miss_date) OR
              NVL(l_old_systems_rec.end_date_active,fnd_api.g_miss_date) = NVL(l_new_systems_rec.end_date_active,fnd_api.g_miss_date) THEN
               l_systems_hist_rec.old_end_date_active := NULL;
               l_systems_hist_rec.new_end_date_active := NULL;
          ELSIF
              NVL(l_old_systems_rec.end_date_active,fnd_api.g_miss_date) <> NVL(l_new_systems_rec.end_date_active,fnd_api.g_miss_date) THEN
               l_systems_hist_rec.old_end_date_active := l_old_systems_rec.end_date_active ;
               l_systems_hist_rec.new_end_date_active := l_new_systems_rec.end_date_active ;
          END IF;
          --
          IF (l_new_systems_rec.autocreated_from_system_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.autocreated_from_system_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.autocreated_from_system_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_autocreated_from_system := NULL;
               l_systems_hist_rec.new_autocreated_from_system := NULL;
          ELSIF
              NVL(l_old_systems_rec.autocreated_from_system_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.autocreated_from_system_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_autocreated_from_system := l_old_systems_rec.autocreated_from_system_id ;
               l_systems_hist_rec.new_autocreated_from_system := l_new_systems_rec.autocreated_from_system_id ;
          END IF;
          --
          IF (l_new_systems_rec.config_system_type = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.config_system_type,fnd_api.g_miss_char) = NVL(l_new_systems_rec.config_system_type,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_config_system_type := NULL;
               l_systems_hist_rec.new_config_system_type := NULL;
          ELSIF
              NVL(l_old_systems_rec.config_system_type,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.config_system_type,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_config_system_type := l_old_systems_rec.config_system_type ;
               l_systems_hist_rec.new_config_system_type := l_new_systems_rec.config_system_type ;
          END IF;
          --
          IF (l_new_systems_rec.context = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.context,fnd_api.g_miss_char) = NVL(l_new_systems_rec.context,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_context := NULL;
               l_systems_hist_rec.new_context := NULL;
          ELSIF
              NVL(l_old_systems_rec.context,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.context,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_context := l_old_systems_rec.context ;
               l_systems_hist_rec.new_context := l_new_systems_rec.context ;
          END IF;
          --
          IF (l_new_systems_rec.attribute1 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute1,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute1,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute1 := NULL;
               l_systems_hist_rec.new_attribute1 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute1,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute1,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute1 := l_old_systems_rec.attribute1 ;
               l_systems_hist_rec.new_attribute1 := l_new_systems_rec.attribute1 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute2 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute2,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute2,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute2 := NULL;
               l_systems_hist_rec.new_attribute2 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute2,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute2,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute2 := l_old_systems_rec.attribute2 ;
               l_systems_hist_rec.new_attribute2 := l_new_systems_rec.attribute2 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute3 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute3,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute3,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute3 := NULL;
               l_systems_hist_rec.new_attribute3 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute3,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute3,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute3 := l_old_systems_rec.attribute3 ;
               l_systems_hist_rec.new_attribute3 := l_new_systems_rec.attribute3 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute4 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute4,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute4,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute4 := NULL;
               l_systems_hist_rec.new_attribute4 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute4,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute4,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute4 := l_old_systems_rec.attribute4 ;
               l_systems_hist_rec.new_attribute4 := l_new_systems_rec.attribute4 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute5 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute5,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute5,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute5 := NULL;
               l_systems_hist_rec.new_attribute5 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute5,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute5,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute5 := l_old_systems_rec.attribute5 ;
               l_systems_hist_rec.new_attribute5 := l_new_systems_rec.attribute5 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute6 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute6,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute6,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute6 := NULL;
               l_systems_hist_rec.new_attribute6 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute6,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute6,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute6 := l_old_systems_rec.attribute6 ;
               l_systems_hist_rec.new_attribute6 := l_new_systems_rec.attribute6 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute7 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute7,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute7,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute7 := NULL;
               l_systems_hist_rec.new_attribute7 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute7,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute7,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute7 := l_old_systems_rec.attribute7 ;
               l_systems_hist_rec.new_attribute7 := l_new_systems_rec.attribute7 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute8 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute8,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute8,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute8 := NULL;
               l_systems_hist_rec.new_attribute8 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute8,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute8,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute8 := l_old_systems_rec.attribute8 ;
               l_systems_hist_rec.new_attribute8 := l_new_systems_rec.attribute8 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute9 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute9,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute9,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute9 := NULL;
               l_systems_hist_rec.new_attribute9 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute9,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute9,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute9 := l_old_systems_rec.attribute9 ;
               l_systems_hist_rec.new_attribute9 := l_new_systems_rec.attribute9 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute10 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute10,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute10,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute10 := NULL;
               l_systems_hist_rec.new_attribute10 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute10,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute10,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute10 := l_old_systems_rec.attribute10 ;
               l_systems_hist_rec.new_attribute10 := l_new_systems_rec.attribute10 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute11 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute11,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute11,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute11 := NULL;
               l_systems_hist_rec.new_attribute11 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute11,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute11,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute11 := l_old_systems_rec.attribute11 ;
               l_systems_hist_rec.new_attribute11 := l_new_systems_rec.attribute11 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute12 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute12,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute12,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute12 := NULL;
               l_systems_hist_rec.new_attribute12 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute12,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute12,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute12 := l_old_systems_rec.attribute12 ;
               l_systems_hist_rec.new_attribute12 := l_new_systems_rec.attribute12 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute13 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute13,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute13,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute13 := NULL;
               l_systems_hist_rec.new_attribute13 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute13,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute13,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute13 := l_old_systems_rec.attribute13 ;
               l_systems_hist_rec.new_attribute13 := l_new_systems_rec.attribute13 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute14 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute14,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute14,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute14 := NULL;
               l_systems_hist_rec.new_attribute14 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute14,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute14,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute14 := l_old_systems_rec.attribute14 ;
               l_systems_hist_rec.new_attribute14 := l_new_systems_rec.attribute14 ;
          END IF;
          --
          IF (l_new_systems_rec.attribute15 = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.attribute15,fnd_api.g_miss_char) = NVL(l_new_systems_rec.attribute15,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute15 := NULL;
               l_systems_hist_rec.new_attribute15 := NULL;
          ELSIF
              NVL(l_old_systems_rec.attribute15,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.attribute15,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_attribute15 := l_old_systems_rec.attribute15 ;
               l_systems_hist_rec.new_attribute15 := l_new_systems_rec.attribute15 ;
          END IF;
          --
          IF (l_new_systems_rec.name = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.name,fnd_api.g_miss_char) = NVL(l_new_systems_rec.name,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_name := NULL;
               l_systems_hist_rec.new_name := NULL;
          ELSIF
              NVL(l_old_systems_rec.name,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.name,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_name := l_old_systems_rec.name ;
               l_systems_hist_rec.new_name := l_new_systems_rec.name ;
          END IF;
          --
          IF (l_new_systems_rec.description = fnd_api.g_miss_char) OR
              NVL(l_old_systems_rec.description,fnd_api.g_miss_char) = NVL(l_new_systems_rec.description,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_description := NULL;
               l_systems_hist_rec.new_description := NULL;
          ELSIF
              NVL(l_old_systems_rec.description,fnd_api.g_miss_char) <> NVL(l_new_systems_rec.description,fnd_api.g_miss_char) THEN
               l_systems_hist_rec.old_description := l_old_systems_rec.description ;
               l_systems_hist_rec.new_description := l_new_systems_rec.description ;
          END IF;
          --
          IF (l_new_systems_rec.operating_unit_id = fnd_api.g_miss_num) OR
              NVL(l_old_systems_rec.operating_unit_id,fnd_api.g_miss_num) = NVL(l_new_systems_rec.operating_unit_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_operating_unit_id := NULL;
               l_systems_hist_rec.new_operating_unit_id := NULL;
          ELSIF
              NVL(l_old_systems_rec.operating_unit_id,fnd_api.g_miss_num) <> NVL(l_new_systems_rec.operating_unit_id,fnd_api.g_miss_num) THEN
               l_systems_hist_rec.old_operating_unit_id := l_old_systems_rec.operating_unit_id ;
               l_systems_hist_rec.new_operating_unit_id := l_new_systems_rec.operating_unit_id ;
          END IF;
          --
          IF p_flag = 'EXPIRE' THEN
               l_systems_hist_rec.new_end_date_active := p_sysdate;
          END IF;

          csi_systems_h_pkg.insert_row(
                     px_system_history_id            => l_systems_hist_rec.system_history_id,
                     p_system_id                     => l_old_systems_rec.system_id,
                     p_transaction_id                => l_transaction_id,
                     p_old_customer_id               => l_systems_hist_rec.old_customer_id,
                     p_new_customer_id               => l_systems_hist_rec.new_customer_id,
                     p_old_system_type_code          => l_systems_hist_rec.old_system_type_code,
                     p_new_system_type_code          => l_systems_hist_rec.new_system_type_code,
                     p_old_system_number             => l_systems_hist_rec.old_system_number,
                     p_new_system_number             => l_systems_hist_rec.new_system_number,
                     p_old_parent_system_id          => l_systems_hist_rec.old_parent_system_id,
                     p_new_parent_system_id          => l_systems_hist_rec.new_parent_system_id,
                     p_old_ship_to_contact_id        => l_systems_hist_rec.old_ship_to_contact_id,
                     p_new_ship_to_contact_id        => l_systems_hist_rec.new_ship_to_contact_id,
                     p_old_bill_to_contact_id        => l_systems_hist_rec.old_bill_to_contact_id,
                     p_new_bill_to_contact_id        => l_systems_hist_rec.new_bill_to_contact_id,
                     p_old_technical_contact_id      => l_systems_hist_rec.old_technical_contact_id,
                     p_new_technical_contact_id      => l_systems_hist_rec.new_technical_contact_id,
                     p_old_service_admin_contact_id  => l_systems_hist_rec.old_service_admin_contact_id,
                     p_new_service_admin_contact_id  => l_systems_hist_rec.new_service_admin_contact_id,
                     p_old_ship_to_site_use_id       => l_systems_hist_rec.old_ship_to_site_use_id,
                     p_new_ship_to_site_use_id       => l_systems_hist_rec.new_ship_to_site_use_id,
                     p_old_install_site_use_id       => l_systems_hist_rec.old_install_site_use_id,
                     p_new_install_site_use_id       => l_systems_hist_rec.new_install_site_use_id,
                     p_old_bill_to_site_use_id       => l_systems_hist_rec.old_bill_to_site_use_id,
                     p_new_bill_to_site_use_id       => l_systems_hist_rec.new_bill_to_site_use_id,
                     p_old_coterminate_day_month     => l_systems_hist_rec.old_coterminate_day_month,
                     p_new_coterminate_day_month     => l_systems_hist_rec.new_coterminate_day_month,
                     p_old_start_date_active         => l_systems_hist_rec.old_start_date_active,
                     p_new_start_date_active         => l_systems_hist_rec.new_start_date_active,
                     p_old_end_date_active           => l_systems_hist_rec.old_end_date_active,
                     p_new_end_date_active           => l_systems_hist_rec.new_end_date_active,
                     p_old_autocreated_from_system   => l_systems_hist_rec.old_autocreated_from_system,
                     p_new_autocreated_from_system   => l_systems_hist_rec.new_autocreated_from_system,
                     p_old_config_system_type        => l_systems_hist_rec.old_config_system_type,
                     p_new_config_system_type        => l_systems_hist_rec.new_config_system_type,
                     p_old_context                   => l_systems_hist_rec.old_context,
                     p_new_context                   => l_systems_hist_rec.new_context,
                     p_old_attribute1                => l_systems_hist_rec.old_attribute1,
                     p_new_attribute1                => l_systems_hist_rec.new_attribute1,
                     p_old_attribute2                => l_systems_hist_rec.old_attribute2,
                     p_new_attribute2                => l_systems_hist_rec.new_attribute2,
                     p_old_attribute3                => l_systems_hist_rec.old_attribute3,
                     p_new_attribute3                => l_systems_hist_rec.new_attribute3,
                     p_old_attribute4                => l_systems_hist_rec.old_attribute4,
                     p_new_attribute4                => l_systems_hist_rec.new_attribute4,
                     p_old_attribute5                => l_systems_hist_rec.old_attribute5,
                     p_new_attribute5                => l_systems_hist_rec.new_attribute5,
                     p_old_attribute6                => l_systems_hist_rec.old_attribute6,
                     p_new_attribute6                => l_systems_hist_rec.new_attribute6,
                     p_old_attribute7                => l_systems_hist_rec.old_attribute7,
                     p_new_attribute7                => l_systems_hist_rec.new_attribute7,
                     p_old_attribute8                => l_systems_hist_rec.old_attribute8,
                     p_new_attribute8                => l_systems_hist_rec.new_attribute8,
                     p_old_attribute9                => l_systems_hist_rec.old_attribute9,
                     p_new_attribute9                => l_systems_hist_rec.new_attribute9,
                     p_old_attribute10               => l_systems_hist_rec.old_attribute10,
                     p_new_attribute10               => l_systems_hist_rec.new_attribute10,
                     p_old_attribute11               => l_systems_hist_rec.old_attribute11,
                     p_new_attribute11               => l_systems_hist_rec.new_attribute11,
                     p_old_attribute12               => l_systems_hist_rec.old_attribute12,
                     p_new_attribute12               => l_systems_hist_rec.new_attribute12,
                     p_old_attribute13               => l_systems_hist_rec.old_attribute13,
                     p_new_attribute13               => l_systems_hist_rec.new_attribute13,
                     p_old_attribute14               => l_systems_hist_rec.old_attribute14,
                     p_new_attribute14               => l_systems_hist_rec.new_attribute14,
                     p_old_attribute15               => l_systems_hist_rec.old_attribute15,
                     p_new_attribute15               => l_systems_hist_rec.new_attribute15,
                     p_full_dump_flag                => 'N',
                     p_created_by                    => fnd_global.user_id,
                     p_creation_date                 => SYSDATE,
                     p_last_updated_by               => fnd_global.user_id,
                     p_last_update_date              => SYSDATE,
                     p_last_update_login             => fnd_global.conc_login_id,
                     p_object_version_number         => 1,
                     p_old_name                      => l_systems_hist_rec.old_name,
                     p_new_name                      => l_systems_hist_rec.new_name,
                     p_old_description               => l_systems_hist_rec.old_description,
                     p_new_description               => l_systems_hist_rec.new_description,
                     p_old_operating_unit_id         => l_systems_hist_rec.old_operating_unit_id,
                     p_new_operating_unit_id         => l_systems_hist_rec.new_operating_unit_id
                     );

     END IF;

   END;
   -- End of modifications for Bug#2547034 on 09/20/02 - rtalluri
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_error;
END;





-- hint: primary key needs to be returned.
PROCEDURE create_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2,
    p_init_msg_list              IN     VARCHAR2,
    p_validation_level           IN     NUMBER,
    p_system_rec                 IN     csi_datastructures_pub.system_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_system_id                  OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'create_system';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_system_id                        NUMBER;
l_system_history_id                NUMBER       :=fnd_api.g_miss_num;
l_debug_level                      NUMBER;
l_name                             VARCHAR2(50);
l_start_date                       DATE;
l_date                             DATE;
l_month                            VARCHAR2(20);
 BEGIN
      -- standard start of api savepoint
      SAVEPOINT create_system_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- debug message


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        IF (l_debug_level > 0) THEN
          csi_gen_utility_pvt.put_line( 'create_system');
        END IF;

        IF (l_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_Commit                  ||'-'||
                                p_Init_Msg_list           ||'-'||
                                p_Validation_level
                                );
            csi_gen_utility_pvt.dump_sys_rec(p_system_rec);
            csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;
      -- invoke validation procedures

      validate_system_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => 'CREATE',
              p_system_id              => p_system_rec.system_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

    validate_auto_sys_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => 'CREATE',
              p_auto_sys_id            => p_system_rec.autocreated_from_system_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

        IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      validate_systems(
          p_init_msg_list    => fnd_api.g_false,
          p_validation_level => p_validation_level,
          p_validation_mode  => 'CREATE',
          p_system_rec       => p_system_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;

       validate_start_end_date(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => 'CREATE',
              p_system_id              => p_system_rec.system_id,
              p_start_date             => p_system_rec.start_date_active,
              p_end_date               => p_system_rec.end_date_active,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
        END IF;

       -- Validate the Operating Unit
	  IF p_system_rec.operating_unit_id is NOT NULL AND
		p_system_rec.operating_unit_id <> FND_API.G_MISS_NUM THEN
		IF NOT csi_org_unit_vld_pvt.Is_Valid_operating_unit_id(p_system_rec.operating_unit_id) THEN
             RAISE fnd_api.g_exc_error;
		END IF;
	  END IF;
	  --
       IF ( (p_system_rec.name IS NULL) OR (p_system_rec.name=fnd_api.g_miss_char) )
       THEN
          IF (fnd_profile.value('CSI_AUTO_GEN_SYS_NAME') = 'Y')
          THEN
           SELECT csi_systems_s.NEXTVAL
           INTO   x_system_id
           FROM   sys.dual;
           l_name := to_char(x_system_id);
          END IF;
       ELSE
          l_name := p_system_rec.name;
       END IF;

       IF (x_return_status = fnd_api.g_ret_sts_success) THEN

        -- check for unique system name
            Check_Unique(
                          p_System_id     =>     NULL
                         ,p_Name          =>     l_name --p_system_rec.name
                         ,p_Customer_ID   =>     p_system_rec.customer_id
                         ,p_System_number =>     p_system_rec.system_number
                         ,x_return_status =>     x_return_status
                         ,x_msg_count     =>     x_msg_count
                         ,x_msg_data      =>     x_msg_data);
        END IF;

        IF   p_system_rec.start_date_active IS NULL
          OR p_system_rec.start_date_active = fnd_api.g_miss_date
        THEN
            l_start_date := SYSDATE;
        ELSE
            l_start_date := p_system_rec.start_date_active;
        END IF;

        IF ((p_system_rec.coterminate_day_month IS NOT NULL) AND
            (p_system_rec.coterminate_day_month <> FND_API.G_MISS_CHAR))
        THEN
           BEGIN
             l_month := p_system_rec.coterminate_day_month||'-1996';
             l_date  := to_date(l_month, 'DD-MM-YYYY');
           EXCEPTION
             WHEN OTHERS THEN
              fnd_message.set_name('CSI','CSI_INVALID_COTERM_DATE');
              fnd_message.set_token('Coterminate_Day_Month',p_system_rec.coterminate_day_month);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END;
        END IF;


        IF x_return_status = fnd_api.g_ret_sts_success THEN
      -- invoke table handler(csi_systems_b_pkg.insert_row)


          csi_systems_b_pkg.insert_row(
            px_system_id                  =>  x_system_id,
            p_customer_id                 =>  p_system_rec.customer_id,
            p_system_type_code            =>  p_system_rec.system_type_code,
            p_system_number               =>  p_system_rec.system_number,
            p_parent_system_id            =>  p_system_rec.parent_system_id,
            p_ship_to_contact_id          =>  p_system_rec.ship_to_contact_id,
            p_bill_to_contact_id          =>  p_system_rec.bill_to_contact_id,
            p_technical_contact_id        =>  p_system_rec.technical_contact_id,
            p_service_admin_contact_id    =>  p_system_rec.service_admin_contact_id,
            p_ship_to_site_use_id         =>  p_system_rec.ship_to_site_use_id,
            p_bill_to_site_use_id         =>  p_system_rec.bill_to_site_use_id,
            p_install_site_use_id         =>  p_system_rec.install_site_use_id,
            p_coterminate_day_month       =>  p_system_rec.coterminate_day_month,
            p_autocreated_from_system_id  =>  p_system_rec.autocreated_from_system_id,
            p_config_system_type          =>  p_system_rec.config_system_type,
            p_start_date_active           =>  l_start_date,
            p_end_date_active             =>  p_system_rec.end_date_active,
            p_context                     =>  p_system_rec.context,
            p_attribute1                  =>  p_system_rec.attribute1,
            p_attribute2                  =>  p_system_rec.attribute2,
            p_attribute3                  =>  p_system_rec.attribute3,
            p_attribute4                  =>  p_system_rec.attribute4,
            p_attribute5                  =>  p_system_rec.attribute5,
            p_attribute6                  =>  p_system_rec.attribute6,
            p_attribute7                  =>  p_system_rec.attribute7,
            p_attribute8                  =>  p_system_rec.attribute8,
            p_attribute9                  =>  p_system_rec.attribute9,
            p_attribute10                 =>  p_system_rec.attribute10,
            p_attribute11                 =>  p_system_rec.attribute11,
            p_attribute12                 =>  p_system_rec.attribute12,
            p_attribute13                 =>  p_system_rec.attribute13,
            p_attribute14                 =>  p_system_rec.attribute14,
            p_attribute15                 =>  p_system_rec.attribute15,
            p_created_by                  =>  fnd_global.user_id,
            p_creation_date               =>  SYSDATE,
            p_last_updated_by             =>  fnd_global.user_id,
            p_last_update_date            =>  SYSDATE,
            p_last_update_login           =>  fnd_global.conc_login_id,
            p_object_version_number       =>  1,
            p_name                        =>  l_name,--p_system_rec.name,
            p_description                 =>  p_system_rec.description,
            p_operating_unit_id           =>  p_system_rec.operating_unit_id,
            p_request_id                  =>  p_system_rec.request_id,
            p_program_application_id      =>  p_system_rec.program_application_id,
            p_program_id                  =>  p_system_rec.program_id,
            p_program_update_date         =>  p_system_rec.program_update_date);
      -- hint: primary key should be returned.
      -- x_system_id := px_system_id;
            l_system_id := x_system_id;

              csi_transactions_pvt.create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_success_if_exists_flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN


              fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_TXN');
              fnd_message.set_token('transaction_id',p_txn_rec.transaction_id );
              fnd_msg_pub.add;

              RAISE fnd_api.g_exc_error;
              RETURN;
         END IF;


       csi_systems_h_pkg.insert_row(
          px_system_history_id              =>  l_system_history_id,
          p_system_id                       =>  l_system_id,
          p_transaction_id                  =>  p_txn_rec.transaction_id,
          p_old_customer_id                 =>  NULL,
          p_new_customer_id                 =>  p_system_rec.customer_id,
          p_old_system_type_code            =>  NULL,
          p_new_system_type_code            =>  p_system_rec.system_type_code,
          p_old_system_number               =>  NULL,
          p_new_system_number               =>  p_system_rec.system_number,
          p_old_parent_system_id            =>  NULL,
          p_new_parent_system_id            =>  p_system_rec.parent_system_id,
          p_old_ship_to_contact_id          =>  NULL,
          p_new_ship_to_contact_id          =>  p_system_rec.ship_to_contact_id,
          p_old_bill_to_contact_id          =>  NULL,
          p_new_bill_to_contact_id          =>  p_system_rec.bill_to_contact_id,
          p_old_technical_contact_id        =>  NULL,
          p_new_technical_contact_id        =>  p_system_rec.technical_contact_id,
          p_old_service_admin_contact_id    =>  NULL,
          p_new_service_admin_contact_id    =>  p_system_rec.service_admin_contact_id,
          p_old_ship_to_site_use_id         =>  NULL,
          p_new_ship_to_site_use_id         =>  p_system_rec.ship_to_site_use_id,
          p_old_install_site_use_id         =>  NULL,
          p_new_install_site_use_id         =>  p_system_rec.install_site_use_id,
          p_old_bill_to_site_use_id         =>  NULL,
          p_new_bill_to_site_use_id         =>  p_system_rec.bill_to_site_use_id,
          p_old_coterminate_day_month       =>  NULL,
          p_new_coterminate_day_month       =>  p_system_rec.coterminate_day_month,
          p_old_start_date_active           =>  NULL,
          p_new_start_date_active           =>  l_start_date,
          p_old_end_date_active             =>  NULL,
          p_new_end_date_active             =>  p_system_rec.end_date_active,
          p_old_autocreated_from_system     =>  NULL,
          p_new_autocreated_from_system     =>  p_system_rec.autocreated_from_system_id,
          p_old_config_system_type          =>  NULL,
          p_new_config_system_type          =>  p_system_rec.config_system_type,
          p_old_context                     =>  NULL,
          p_new_context                     =>  p_system_rec.context,
          p_old_attribute1                  =>  NULL,
          p_new_attribute1                  =>  p_system_rec.attribute1,
          p_old_attribute2                  =>  NULL,
          p_new_attribute2                  =>  p_system_rec.attribute2,
          p_old_attribute3                  =>  NULL,
          p_new_attribute3                  =>  p_system_rec.attribute3,
          p_old_attribute4                  =>  NULL,
          p_new_attribute4                  =>  p_system_rec.attribute4,
          p_old_attribute5                  =>  NULL,
          p_new_attribute5                  =>  p_system_rec.attribute5,
          p_old_attribute6                  =>  NULL,
          p_new_attribute6                  =>  p_system_rec.attribute6,
          p_old_attribute7                  =>  NULL,
          p_new_attribute7                  =>  p_system_rec.attribute7,
          p_old_attribute8                  =>  NULL,
          p_new_attribute8                  =>  p_system_rec.attribute8,
          p_old_attribute9                  =>  NULL,
          p_new_attribute9                  =>  p_system_rec.attribute9,
          p_old_attribute10                 =>  NULL,
          p_new_attribute10                 =>  p_system_rec.attribute10,
          p_old_attribute11                 =>  NULL,
          p_new_attribute11                 =>  p_system_rec.attribute11,
          p_old_attribute12                 =>  NULL,
          p_new_attribute12                 =>  p_system_rec.attribute12,
          p_old_attribute13                 =>  NULL,
          p_new_attribute13                 =>  p_system_rec.attribute13,
          p_old_attribute14                 =>  NULL,
          p_new_attribute14                 =>  p_system_rec.attribute14,
          p_old_attribute15                 =>  NULL,
          p_new_attribute15                 =>  p_system_rec.attribute15,
          p_full_dump_flag                  =>  'Y',
          p_created_by                      =>  fnd_global.user_id,
          p_creation_date                   =>  SYSDATE,
          p_last_updated_by                 =>  fnd_global.user_id,
          p_last_update_date                =>  SYSDATE,
          p_last_update_login               =>  fnd_global.conc_login_id,
          p_object_version_number           =>  1,
          p_old_name                        =>  NULL,
          p_new_name                        =>  l_name, --p_system_rec.name,
          p_old_description                 =>  NULL,
          p_new_description                 =>  p_system_rec.description,
		p_old_operating_unit_id           =>  NULL,
		p_new_operating_unit_id           =>  p_system_rec.operating_unit_id) ;


        END IF;





          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      --
      -- END of api body
      --

      -- standard check FOR p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO create_system_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO create_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO create_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END create_system;



PROCEDURE update_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2,
    p_init_msg_list              IN     VARCHAR2,
    p_validation_level           IN     NUMBER,
    p_system_rec                 IN     csi_datastructures_pub.system_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )
 IS
  --
CURSOR  systems_csr (sys_id NUMBER) IS
     SELECT system_id,
            customer_id,
            system_type_code,
            system_number,
            parent_system_id,
            ship_to_contact_id,
            bill_to_contact_id,
            technical_contact_id,
            service_admin_contact_id,
            ship_to_site_use_id,
            bill_to_site_use_id,
            install_site_use_id,
            coterminate_day_month,
            start_date_active,
            end_date_active,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            object_version_number,
		  operating_unit_id
     FROM   csi_systems_b
     WHERE  system_id=sys_id
     FOR UPDATE OF object_version_number ;

CURSOR  tl_csr (sys_id NUMBER) IS
    SELECT name,
           description
    FROM   csi_systems_tl
    WHERE  system_id=sys_id
    FOR UPDATE OF system_id ;

CURSOR cont_csr IS
    SELECT party_id
    FROM   csi_i_parties cip, csi_item_instances cii
    WHERE  cip.instance_id=cii.instance_id
    AND    cii.system_id=p_system_rec.system_id
    AND    cip.relationship_type_code='OWNER'
    AND    sysdate BETWEEN NVL(cii.active_start_date,sysdate)
                   AND     NVL(cii.active_end_date,sysdate);

CURSOR site_csr IS
    SELECT ip_account_id
    FROM   csi_item_instances cii,
           csi_i_parties cip,
           csi_ip_accounts cia
    WHERE  cii.instance_id=cip.instance_id
    AND    cii.system_id=p_system_rec.system_id
    AND    cip.instance_party_id=cia.instance_party_id
    AND    cia.relationship_type_code='OWNER'
    AND    sysdate BETWEEN NVL(cii.active_start_date,sysdate)
                   AND     NVL(cii.active_end_date,sysdate);
CURSOR ins_csr IS
   SELECT cip.instance_id instance_id,cip.instance_party_id instance_party_id,
          cip.object_version_number party_obj_version_number
         ,cia.ip_account_id ip_account_id,cia.object_version_number account_obj_version_number
   FROM CSI_ITEM_INSTANCES cii,
        CSI_I_PARTIES cip,
        CSI_IP_ACCOUNTS cia
   WHERE cii.system_id = p_system_rec.system_id
   AND   cip.instance_id = cii.instance_id
   AND   cip.relationship_type_code='OWNER'
   AND   cip.instance_party_id=cia.instance_party_id
   AND   cia.relationship_type_code='OWNER'
   AND   sysdate BETWEEN NVL(cii.active_start_date,sysdate) AND NVL(cii.active_end_date,sysdate)
   AND   sysdate BETWEEN NVL(cip.active_start_date,sysdate) AND NVL(cip.active_end_date,sysdate)
   AND   sysdate BETWEEN NVL(cia.active_start_date,sysdate) AND NVL(cia.active_end_date,sysdate);
--
CURSOR ip_acct_csr(p_bill_to IN NUMBER,p_ship_to IN NUMBER) IS
   SELECT cia.ip_account_id ip_account_id,cia.object_version_number object_version_number
         ,cia.bill_to_address,cia.ship_to_address
   FROM CSI_ITEM_INSTANCES cii,
        CSI_I_PARTIES cip,
        CSI_IP_ACCOUNTS cia
   WHERE cii.system_id = p_system_rec.system_id
   AND   cip.instance_id = cii.instance_id
   AND   cip.relationship_type_code='OWNER'
   AND   cip.instance_party_id=cia.instance_party_id
   AND   cia.relationship_type_code='OWNER'
   AND   sysdate BETWEEN NVL(cii.active_start_date,sysdate) AND NVL(cii.active_end_date,sysdate)
   AND   sysdate BETWEEN NVL(cip.active_start_date,sysdate) AND NVL(cip.active_end_date,sysdate)
   AND   sysdate BETWEEN NVL(cia.active_start_date,sysdate) AND NVL(cia.active_end_date,sysdate)
   AND   ((NVL(cia.bill_to_address,-999) = NVL(p_bill_to,-999)) OR
          (NVL(cia.ship_to_address,-999) = NVL(p_ship_to,-999))) ;
--
CURSOR ins_party_csr IS
   SELECT cip.instance_party_id instance_party_id
   FROM CSI_ITEM_INSTANCES cii,
        CSI_I_PARTIES cip
   WHERE cii.system_id = p_system_rec.system_id
   AND   cip.instance_id = cii.instance_id
   AND   cip.relationship_type_code = 'OWNER'
   AND   sysdate BETWEEN NVL(cii.active_start_date,sysdate) AND NVL(cii.active_end_date,sysdate)
   AND   sysdate BETWEEN NVL(cip.active_start_date,sysdate) AND NVL(cip.active_end_date,sysdate);
--
CURSOR contact_ip_csr(p_contact_ip_id IN NUMBER) IS
   SELECT instance_party_id,object_version_number,party_id,relationship_type_code
   FROM CSI_I_PARTIES
   WHERE contact_ip_id = p_contact_ip_id
   AND   contact_flag = 'Y'
   AND   party_source_table = 'HZ_PARTIES'
   AND   sysdate BETWEEN NVL(active_start_date,sysdate) AND NVL(active_end_date,sysdate);
--
CURSOR install_csr(p_sys_id IN NUMBER) IS
   SELECT instance_id, install_location_id, object_version_number
   FROM   CSI_ITEM_INSTANCES
   WHERE  sysdate BETWEEN NVL(active_start_date,sysdate) AND NVL(active_end_date,sysdate)
   AND    system_id = p_sys_id;
--
   l_msg_count                        NUMBER;
   l_msg_data                         VARCHAR2(2000);
   l_msg_index                        NUMBER;
   l_dummy                            VARCHAR2(1):='N';
   l_sys_csr                          systems_csr%ROWTYPE;
   l_tl_csr                           tl_csr%ROWTYPE;
   l_api_name                CONSTANT VARCHAR2(30) := 'update_system';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_rowid                            rowid;
   l_object_version_number            NUMBER;
   l_old_systems_rec                  csi_datastructures_pub.system_rec;
   l_new_systems_rec                  csi_datastructures_pub.system_rec:=p_system_rec;
   l_systems_hist_rec                 csi_datastructures_pub.system_history_rec;
   l_count                            NUMBER;
   l_full_dump                        NUMBER;
   l_debug_level                      NUMBER;
   l_customer_id                      NUMBER;
   l_instance_id_lst                  csi_datastructures_pub.id_tbl;
   l_transaction_date                 DATE;
   l_party_id                         NUMBER;
   l_party_tbl                        csi_datastructures_pub.party_tbl;
   l_party_account_tbl                csi_datastructures_pub.party_account_tbl;
   l_init_party_tbl                   csi_datastructures_pub.party_tbl;
   l_init_party_account_tbl           csi_datastructures_pub.party_account_tbl;
   l_bill_to                          NUMBER;
   l_ship_to                          NUMBER;
   l_contact_party_id                 NUMBER;
   l_call_flag                        VARCHAR2(1);
   l_date                             DATE;
   l_month                            VARCHAR2(20);
   l_exists                           VARCHAR2(1);
   l_xfer_flag                        VARCHAR2(1);
   l_bill_to_address                  NUMBER;
   l_ship_to_address                  NUMBER;
   --
   l_item_attribute_tbl               csi_item_instance_pvt.item_attribute_tbl;
   l_location_tbl                     csi_item_instance_pvt.location_tbl;
   l_generic_id_tbl                   csi_item_instance_pvt.generic_id_tbl;
   l_lookup_tbl                       csi_item_instance_pvt.lookup_tbl;
   l_ins_count_rec                    csi_item_instance_pvt.ins_count_rec;
   l_instance_rec                     csi_datastructures_pub.instance_rec;
   l_temp_instance_rec                csi_datastructures_pub.instance_rec;
   l_install_to                       NUMBER;
   px_oks_txn_inst_tbl                oks_ibint_pub.txn_instance_tbl;
   px_child_inst_tbl                  csi_item_instance_grp.child_inst_tbl;
   l_batch_id                         NUMBER;
   l_batch_type                       VARCHAR2(50);
   --
   Process_next                       EXCEPTION;

 BEGIN
      -- standard start of api savepoint
      SAVEPOINT update_system_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;



      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        IF (l_debug_level > 0) THEN
          csi_gen_utility_pvt.put_line( 'update_system');
        END IF;

        IF (l_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_Commit                  ||'-'||
                                p_Init_Msg_list           ||'-'||
                                p_Validation_level
                                );
            csi_gen_utility_pvt.dump_sys_rec(p_system_rec);
            csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;
        --
        IF p_system_rec.customer_id IS NULL THEN
           fnd_message.set_name('CSI', 'CSI_API_MANDATORY_CUSTOMER');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        END IF;
        --
        IF p_system_rec.system_type_code IS NULL THEN
           fnd_message.set_name('CSI', 'CSI_API_MANDATORY_SYSTEM_TYPE');
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
        END IF;
        --

      OPEN systems_csr (p_system_rec.system_id);
      FETCH systems_csr INTO l_sys_csr;
       IF ( (l_sys_csr.object_version_number<>p_system_rec.object_version_number)
         AND (p_system_rec.object_version_number <> fnd_api.g_miss_num) ) THEN
         fnd_message.set_name('CSI', 'CSI_RECORD_CHANGED');
          fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
       END IF;
      CLOSE systems_csr;

      OPEN tl_csr (p_system_rec.system_id);
      FETCH tl_csr INTO l_tl_csr;
      CLOSE tl_csr;


      -- invoke validation procedures
      validate_system_id(
                p_init_msg_list          => fnd_api.g_false,
                p_validation_mode        => 'UPDATE',
                p_system_id              => p_system_rec.system_id,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data);

      validate_object_version_num(
                p_init_msg_list          => fnd_api.g_false,
                p_validation_mode        => 'UPDATE',
                p_object_version_number  => p_system_rec.object_version_number,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data);

            IF x_return_status<>fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
            END IF;

      validate_systems(
                p_init_msg_list           => fnd_api.g_false,
                p_validation_level        => p_validation_level,
                p_validation_mode         => 'UPDATE',
                p_system_rec              => p_system_rec,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data);

      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;

       validate_start_end_date(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => 'UPDATE',
              p_system_id              => p_system_rec.system_id,
              p_start_date             => p_system_rec.start_date_active,
              p_end_date               => p_system_rec.end_date_active,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
        END IF;

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN

        IF( (p_system_rec.parent_system_id IS NOT NULL) AND (p_system_rec.parent_system_id <> fnd_api.g_miss_num)) THEN

           check_parent_child_constraint(x_system_id            =>  p_system_rec.system_id,
                                         x_parent_system_id     =>  p_system_rec.parent_system_id,
                                         x_return_status        =>  x_return_status,
                                         x_msg_count            =>  x_msg_count,
                                         x_msg_data             =>  x_msg_data);
        END IF;
      END IF;
      IF ( (p_system_rec.customer_id IS NOT NULL) AND (p_system_rec.customer_id<>fnd_api.g_miss_num) ) THEN
         l_customer_id:=p_system_rec.customer_id;
      ELSE
         l_customer_id:=l_sys_csr.customer_id;
      END IF;


      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- check for unique system name
            Check_Unique(
                          p_System_id     =>     p_system_rec.system_id
                         ,p_Name          =>     p_system_rec.name
                         ,p_Customer_ID   =>     l_customer_id
                         ,p_System_number =>     p_system_rec.system_number
                         ,x_return_status =>     x_return_status
                         ,x_msg_count     =>     x_msg_count
                         ,x_msg_data      =>     x_msg_data);

        END IF;

        IF ((p_system_rec.coterminate_day_month IS NOT NULL) AND
            (p_system_rec.coterminate_day_month <> FND_API.G_MISS_CHAR))
        THEN
           BEGIN
             l_month := p_system_rec.coterminate_day_month||'-1996';
             l_date  := to_date(l_month, 'DD-MM-YYYY');
           EXCEPTION
             WHEN OTHERS THEN
              fnd_message.set_name('CSI','CSI_INVALID_COTERM_DATE');
              fnd_message.set_token('Coterminate_Day_Month',p_system_rec.coterminate_day_month);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END;
        END IF;

      -- Validate Operating_unit_id
	 IF p_system_rec.operating_unit_id IS NOT NULL AND
	    p_system_rec.operating_unit_id <> FND_API.G_MISS_NUM AND
	    p_system_rec.operating_unit_id <> nvl(l_sys_csr.operating_unit_id,-999) THEN
	    IF NOT csi_org_unit_vld_pvt.Is_Valid_operating_unit_id(p_system_rec.operating_unit_id) THEN
            RAISE fnd_api.g_exc_error;
	    END IF;
      END IF;
	 --
      csi_gen_utility_pvt.put_line('p_system_rec.end_date_active is '||to_char(p_system_rec.end_date_active,'DD-MON-YYYY HH24:MI:SS'));
      IF   (p_system_rec.end_date_active IS NOT NULL
       AND p_system_rec.end_date_active <> fnd_api.g_miss_date
	  AND p_system_rec.end_date_active <> nvl(l_sys_csr.end_date_active,fnd_api.g_miss_date)
       AND p_system_rec.end_date_active >= SYSDATE)
                    -- srramakr. Since HTML has the time component, TRUNC has been removed.
      THEN
      csi_systems_pvt.expire_system(
                 p_api_version       => p_api_version,
                 p_commit            => fnd_api.g_false,
                 p_init_msg_list     => p_init_msg_list,
                 p_validation_level  => p_validation_level,
                 p_system_rec        => p_system_rec,
                 p_txn_rec           => p_txn_rec,
                 x_instance_id_lst   => l_instance_id_lst,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data
                  );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('CSI','CSI_FAILED_TO_EXPIRE_SYSTEM');
              fnd_message.set_token('SYSTEM_ID',p_system_rec.system_id );
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF ( p_system_rec.end_date_active IS NOT NULL
          AND p_system_rec.end_date_active <> fnd_api.g_miss_date
	     AND p_system_rec.end_date_active <> nvl(l_sys_csr.end_date_active,fnd_api.g_miss_date)
          AND p_system_rec.end_date_active < SYSDATE)
                    -- srramakr. Since HTML has the time component, TRUNC has been removed.
      THEN
        BEGIN
          SELECT MAX(t.transaction_date)
          INTO   l_transaction_date
          FROM   csi_systems_h s,
                 csi_transactions t
          WHERE  s.system_id=p_system_rec.system_id
          AND    s.transaction_id=t.transaction_id;
          -- srramakar. Exception handled right after select rather than at the end.
          -- Group function does not raise exception. Since it was there I am leaving as it is.
        EXCEPTION
          WHEN OTHERS THEN
           NULL;
        END;

          IF l_transaction_date > p_system_rec.end_date_active
          THEN
            fnd_message.set_name('CSI','CSI_HAS_TXNS');
            fnd_message.set_token('END_DATE_ACTIVE',p_system_rec.end_date_active );
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
	    -- srramakr. If the Active end date is < sysdate, then call to Expire_System
	    -- was missed. Fixed as a part of Bug 2230262.
          ELSE
		  csi_systems_pvt.expire_system(
				   p_api_version       => p_api_version,
				   p_commit            => fnd_api.g_false,
				   p_init_msg_list     => p_init_msg_list,
				   p_validation_level  => p_validation_level,
				   p_system_rec        => p_system_rec,
				   p_txn_rec           => p_txn_rec,
				   x_instance_id_lst   => l_instance_id_lst,
				   x_return_status     => x_return_status,
				   x_msg_count         => x_msg_count,
				   x_msg_data          => x_msg_data
				    );

			IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
				fnd_message.set_name('CSI','CSI_FAILED_TO_EXPIRE_SYSTEM');
				fnd_message.set_token('SYSTEM_ID',p_system_rec.system_id );
				fnd_msg_pub.add;
				RAISE fnd_api.g_exc_error;
			END IF;
          END IF;
          -- The exception has moved up since any Raise wihin the block will hit this exception
          -- rather than going to the actual fnd_api.g_exc_error.
      ELSE

        IF x_return_status = fnd_api.g_ret_sts_success THEN
          -- invoke table handler(csi_systems_b_pkg.update_row)
          IF p_txn_rec.source_group_ref = 'XFER' THEN

           csi_systems_b_pkg.update_row_for_mu(
                    p_system_id                   =>  p_system_rec.system_id,
                    p_customer_id                 =>  p_system_rec.customer_id,
                    p_system_type_code            =>  p_system_rec.system_type_code,
                    p_system_number               =>  p_system_rec.system_number,
                    p_parent_system_id            =>  p_system_rec.parent_system_id,
                    p_ship_to_contact_id          =>  p_system_rec.ship_to_contact_id,
                    p_bill_to_contact_id          =>  p_system_rec.bill_to_contact_id,
                    p_technical_contact_id        =>  p_system_rec.technical_contact_id,
                    p_service_admin_contact_id    =>  p_system_rec.service_admin_contact_id,
                    p_ship_to_site_use_id         =>  p_system_rec.ship_to_site_use_id,
                    p_bill_to_site_use_id         =>  p_system_rec.bill_to_site_use_id,
                    p_install_site_use_id         =>  p_system_rec.install_site_use_id,
                    p_coterminate_day_month       =>  p_system_rec.coterminate_day_month,
                    p_autocreated_from_system_id  =>  p_system_rec.autocreated_from_system_id,
                    p_start_date_active           =>  p_system_rec.start_date_active,
                    p_end_date_active             =>  p_system_rec.end_date_active,
                    p_context                     =>  p_system_rec.context,
                    p_attribute1                  =>  p_system_rec.attribute1,
                    p_attribute2                  =>  p_system_rec.attribute2,
                    p_attribute3                  =>  p_system_rec.attribute3,
                    p_attribute4                  =>  p_system_rec.attribute4,
                    p_attribute5                  =>  p_system_rec.attribute5,
                    p_attribute6                  =>  p_system_rec.attribute6,
                    p_attribute7                  =>  p_system_rec.attribute7,
                    p_attribute8                  =>  p_system_rec.attribute8,
                    p_attribute9                  =>  p_system_rec.attribute9,
                    p_attribute10                 =>  p_system_rec.attribute10,
                    p_attribute11                 =>  p_system_rec.attribute11,
                    p_attribute12                 =>  p_system_rec.attribute12,
                    p_attribute13                 =>  p_system_rec.attribute13,
                    p_attribute14                 =>  p_system_rec.attribute14,
                    p_attribute15                 =>  p_system_rec.attribute15,
                    p_created_by                  =>  fnd_api.g_miss_num,
                    p_creation_date               =>  fnd_api.g_miss_date,
                    p_last_updated_by             =>  fnd_global.user_id,
                    p_last_update_date            =>  SYSDATE,
                    p_last_update_login           =>  fnd_global.conc_login_id,
                    p_object_version_number       =>  p_system_rec.object_version_number,
                    p_name                        =>  p_system_rec.name,
                    p_description                 =>  p_system_rec.description,
                    p_operating_unit_id           =>  p_system_rec.operating_unit_id,
                    p_request_id                  =>  p_system_rec.request_id,
                    p_program_application_id      =>  p_system_rec.program_application_id,
                    p_program_id                  =>  p_system_rec.program_id,
                    p_program_update_date         =>  p_system_rec.program_update_date);
          ELSE

          csi_systems_b_pkg.update_row(
                    p_system_id                   =>  p_system_rec.system_id,
                    p_customer_id                 =>  p_system_rec.customer_id,
                    p_system_type_code            =>  p_system_rec.system_type_code,
                    p_system_number               =>  p_system_rec.system_number,
                    p_parent_system_id            =>  p_system_rec.parent_system_id,
                    p_ship_to_contact_id          =>  p_system_rec.ship_to_contact_id,
                    p_bill_to_contact_id          =>  p_system_rec.bill_to_contact_id,
                    p_technical_contact_id        =>  p_system_rec.technical_contact_id,
                    p_service_admin_contact_id    =>  p_system_rec.service_admin_contact_id,
                    p_ship_to_site_use_id         =>  p_system_rec.ship_to_site_use_id,
                    p_bill_to_site_use_id         =>  p_system_rec.bill_to_site_use_id,
                    p_install_site_use_id         =>  p_system_rec.install_site_use_id,
                    p_coterminate_day_month       =>  p_system_rec.coterminate_day_month,
                    p_autocreated_from_system_id  =>  p_system_rec.autocreated_from_system_id,
                    p_start_date_active           =>  p_system_rec.start_date_active,
                    p_end_date_active             =>  p_system_rec.end_date_active,
                    p_context                     =>  p_system_rec.context,
                    p_attribute1                  =>  p_system_rec.attribute1,
                    p_attribute2                  =>  p_system_rec.attribute2,
                    p_attribute3                  =>  p_system_rec.attribute3,
                    p_attribute4                  =>  p_system_rec.attribute4,
                    p_attribute5                  =>  p_system_rec.attribute5,
                    p_attribute6                  =>  p_system_rec.attribute6,
                    p_attribute7                  =>  p_system_rec.attribute7,
                    p_attribute8                  =>  p_system_rec.attribute8,
                    p_attribute9                  =>  p_system_rec.attribute9,
                    p_attribute10                 =>  p_system_rec.attribute10,
                    p_attribute11                 =>  p_system_rec.attribute11,
                    p_attribute12                 =>  p_system_rec.attribute12,
                    p_attribute13                 =>  p_system_rec.attribute13,
                    p_attribute14                 =>  p_system_rec.attribute14,
                    p_attribute15                 =>  p_system_rec.attribute15,
                    p_created_by                  =>  fnd_api.g_miss_num,
                    p_creation_date               =>  fnd_api.g_miss_date,
                    p_last_updated_by             =>  fnd_global.user_id,
                    p_last_update_date            =>  SYSDATE,
                    p_last_update_login           =>  fnd_global.conc_login_id,
                    p_object_version_number       =>  p_system_rec.object_version_number,
                    p_name                        =>  p_system_rec.name,
                    p_description                 =>  p_system_rec.description,
                    p_operating_unit_id           =>  p_system_rec.operating_unit_id,
                    p_request_id                  =>  p_system_rec.request_id,
                    p_program_application_id      =>  p_system_rec.program_application_id,
                    p_program_id                  =>  p_system_rec.program_id,
                    p_program_update_date         =>  p_system_rec.program_update_date);
           END IF;

            csi_transactions_pvt.create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_success_if_exists_flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_TXN');
              fnd_message.set_token('transaction_id',p_txn_rec.transaction_id );
                  fnd_msg_pub.add;

              RAISE fnd_api.g_exc_error;
              RETURN;
         END IF;

            l_old_systems_rec.system_id:=l_sys_csr.system_id;
            l_old_systems_rec.customer_id:=l_sys_csr.customer_id;
            l_old_systems_rec.system_type_code:=l_sys_csr.system_type_code;
            l_old_systems_rec.system_number:=l_sys_csr.system_number;
            l_old_systems_rec.parent_system_id:=l_sys_csr.parent_system_id;
            l_old_systems_rec.ship_to_contact_id:=l_sys_csr.ship_to_contact_id;
            l_old_systems_rec.bill_to_contact_id:=l_sys_csr.bill_to_contact_id;
            l_old_systems_rec.technical_contact_id:=l_sys_csr.technical_contact_id;
            l_old_systems_rec.service_admin_contact_id:=l_sys_csr.service_admin_contact_id;
            l_old_systems_rec.ship_to_site_use_id:=l_sys_csr.ship_to_site_use_id;
            l_old_systems_rec.bill_to_site_use_id:=l_sys_csr.bill_to_site_use_id;
            l_old_systems_rec.install_site_use_id:=l_sys_csr.install_site_use_id;
            l_old_systems_rec.coterminate_day_month:=l_sys_csr.coterminate_day_month;
            l_old_systems_rec.start_date_active:=l_sys_csr.start_date_active;
            l_old_systems_rec.end_date_active:=l_sys_csr.end_date_active;
            l_old_systems_rec.context:=l_sys_csr.context;
            l_old_systems_rec.attribute1:=l_sys_csr.attribute1;
            l_old_systems_rec.attribute2:=l_sys_csr.attribute2;
            l_old_systems_rec.attribute3:=l_sys_csr.attribute3;
            l_old_systems_rec.attribute4:=l_sys_csr.attribute4;
            l_old_systems_rec.attribute5:=l_sys_csr.attribute5;
            l_old_systems_rec.attribute6:=l_sys_csr.attribute6;
            l_old_systems_rec.attribute7:=l_sys_csr.attribute7;
            l_old_systems_rec.attribute8:=l_sys_csr.attribute8;
            l_old_systems_rec.attribute9:=l_sys_csr.attribute9;
            l_old_systems_rec.attribute10:=l_sys_csr.attribute10;
            l_old_systems_rec.attribute11:=l_sys_csr.attribute11;
            l_old_systems_rec.attribute12:=l_sys_csr.attribute12;
            l_old_systems_rec.attribute13:=l_sys_csr.attribute13;
            l_old_systems_rec.attribute14:=l_sys_csr.attribute14;
            l_old_systems_rec.attribute15:=l_sys_csr.attribute15;
            l_old_systems_rec.object_version_number:=l_sys_csr.object_version_number;
            l_old_systems_rec.name:=l_tl_csr.name;
            l_old_systems_rec.description:=l_tl_csr.description;
		  l_old_systems_rec.operating_unit_id := l_sys_csr.operating_unit_id;

                validate_history(p_old_systems_rec  =>  l_old_systems_rec,
                                 p_new_systems_rec  =>  l_new_systems_rec,
                                 p_transaction_id   =>  p_txn_rec.transaction_id,
                                 p_flag             =>  NULL,
                                 p_sysdate          =>  NULL,
                                 x_return_status    =>  x_return_status,
                                 x_msg_count        =>  x_msg_count,
                                 x_msg_data         =>  x_msg_data
                                 );


     /************* COMMENTED SINCE API SHOULD BE CALLED RATHER THAN DIRECT UPDATE
       check version 115.54 for the old code
     ***********************  END OF COMMENT ****************/
   END IF;
      -- Bug # 2199317 srramakr
      -- When a system is Xferred, based on Cascade_cust_to_inst_flag, we need to cascade the account
      -- changes to Instances.
      l_xfer_flag := 'N';

      IF ( (p_system_rec.customer_id IS NOT NULL) AND (p_system_rec.customer_id<>fnd_api.g_miss_num) AND
           (p_system_rec.customer_id <> l_sys_csr.customer_id) AND
           (nvl(p_system_rec.CASCADE_CUST_TO_INS_FLAG,'N') = 'Y') ) THEN
	 Begin
	    select party_id
	    into l_party_id
	    from HZ_CUST_ACCOUNTS
	    where cust_account_id = p_system_rec.customer_id;
	 Exception
	    when others then
	       null;
	 End;
         --
         l_xfer_flag := 'Y';
         -- srramakr Bug 3621181. Bill_to and Ship_to should get changed accordingly
         IF nvl(p_system_rec.bill_to_site_use_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            l_bill_to_address := null;
         ELSE
            l_bill_to_address := p_system_rec.bill_to_site_use_id;
         END IF;
         --
         IF nvl(p_system_rec.ship_to_site_use_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            l_ship_to_address := null;
         ELSE
            l_ship_to_address := p_system_rec.ship_to_site_use_id;
         END IF;
         --
         For v_rec in ins_csr
         Loop
            Begin
               l_exists := 'N';
               Begin
                  select 'Y'
                  into l_exists
                  from CSI_ITEM_INSTANCES
                  where instance_id = v_rec.instance_id
                  and   owner_party_id = l_party_id
                  and   nvl(owner_party_account_id,-999) = p_system_rec.customer_id;
               Exception
                  when no_data_found then
                     l_exists := 'N';
               End;
               --
               -- srramakr Bug # 3531056
               -- If the child instance also belongs to the same system then the ownership would have got
               -- cascaded from the parent. So, there is no need to change the owner again.
               IF l_exists = 'Y' THEN
                  csi_gen_utility_pvt.put_line('Instance '||to_char(v_rec.instance_id)||'  Already Transfered');
                  Raise Process_next;
               END IF;
               --
	       l_party_tbl := l_init_party_tbl;
	       l_party_account_tbl := l_init_party_account_tbl;
	       l_party_tbl(1).party_id := l_party_id;
	       l_party_tbl(1).instance_id := v_rec.instance_id;
	       l_party_tbl(1).instance_party_id := v_rec.instance_party_id;
	       l_party_tbl(1).relationship_type_code := 'OWNER';
	       l_party_tbl(1).object_version_number := v_rec.party_obj_version_number;
	       l_party_account_tbl(1).instance_party_id := v_rec.instance_party_id;
	       l_party_account_tbl(1).parent_tbl_index := 1;
	       l_party_account_tbl(1).party_account_id := p_system_rec.customer_id;
	       l_party_account_tbl(1).relationship_type_code := 'OWNER';
	       l_party_account_tbl(1).object_version_number := v_rec.account_obj_version_number;
	       l_party_account_tbl(1).system_id := p_system_rec.system_id;
               l_party_account_tbl(1).bill_to_address := l_bill_to_address;
               l_party_account_tbl(1).ship_to_address := l_ship_to_address;
	       --
	       csi_party_relationships_pub.update_inst_party_relationship
		   (p_api_version      => p_api_version
		   ,p_commit           => fnd_api.g_false
		   ,p_init_msg_list    => p_init_msg_list
		   ,p_validation_level => p_validation_level
		   ,p_party_tbl        => l_party_tbl
		   ,p_party_account_tbl=> l_party_account_tbl
		   ,p_txn_rec          => p_txn_rec
                   ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
		   ,x_return_status    => x_return_status
		   ,x_msg_count        => x_msg_count
		   ,x_msg_data         => x_msg_data
		     );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  csi_gen_utility_pvt.put_line('Error from CSI_PARTY_RELATIONSHIPS_PUB.. ');
		  l_msg_index := 1;
		  l_msg_count := x_msg_count;
		  WHILE l_msg_count > 0
		     LOOP
			x_msg_data := FND_MSG_PUB.GET
				       ( l_msg_index,
					 FND_API.G_FALSE );
			 csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			 l_msg_index := l_msg_index + 1;
			 l_msg_count := l_msg_count - 1;
		      END LOOP;
		      RAISE FND_API.G_EXC_ERROR;
	       END IF;
            Exception
               when Process_next then
                  null;
            End;
         End Loop;
         --
         IF px_oks_txn_inst_tbl.count > 0 THEN
            csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
            csi_gen_utility_pvt.put_line('Calling OKS Core API...');
	    --
	    IF p_txn_rec.transaction_type_id = 3 THEN
	       l_batch_id := p_txn_rec.source_header_ref_id;
	       l_batch_type := p_txn_rec.source_group_ref;
	    ELSE
	       l_batch_id := NULL;
	       l_batch_type := NULL;
	    END IF;
	    --
            UPDATE CSI_TRANSACTIONS
            set contracts_invoked = 'Y'
            where transaction_id = p_txn_rec.transaction_id;
            --
	    OKS_IBINT_PUB.IB_interface
	       (
		 P_Api_Version           =>  1.0,
		 P_init_msg_list         =>  p_init_msg_list,
		 P_single_txn_date_flag  =>  'Y',
		 P_Batch_type            =>  l_batch_type,
		 P_Batch_ID              =>  l_batch_id,
		 P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
		 x_return_status         =>  x_return_status,
		 x_msg_count             =>  x_msg_count,
		 x_msg_data              =>  x_msg_data
	      );
	    --
	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	       l_msg_index := 1;
	       l_msg_count := x_msg_count;
	       WHILE l_msg_count > 0 LOOP
		  x_msg_data := FND_MSG_PUB.GET
			  (  l_msg_index,
			     FND_API.G_FALSE        );
		  csi_gen_utility_pvt.put_line( 'Error from OKS_IBINT_PUB.IB_interface..');
		  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	       END LOOP;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END IF;
      END IF;
      --
      --
      -- Bug # 3072178 rtalluri
      -- When a install_site_use_id changes for a system, then the install details should be cascaded to
      -- all the underlying instances associated to the system
      --
      If ( ((nvl(p_system_rec.install_site_use_id,-999) <> fnd_api.g_miss_num) AND
            (nvl(p_system_rec.install_site_use_id,-999) <> nvl(l_sys_csr.install_site_use_id,-999))) AND
            (nvl(p_system_rec.INSTALL_TO_SITE_CHANGE_FLAG,'N') = 'Y') )
      Then

         For v_install_rec in install_csr(l_sys_csr.system_id)
         Loop
            Begin
	       l_instance_rec :=l_temp_instance_rec;
	       l_call_flag := 'N';
	       IF nvl(v_install_rec.install_location_id,-999) = nvl(l_sys_csr.install_site_use_id,-999) THEN
		  IF p_system_rec.install_site_use_id = FND_API.G_MISS_NUM OR
		     nvl(p_system_rec.INSTALL_TO_SITE_CHANGE_FLAG,'N') <> 'Y' THEN
		     l_install_to := v_install_rec.install_location_id;
		  ELSE
		     l_install_to := p_system_rec.install_site_use_id;
		     l_call_flag := 'Y';
		  END IF;
	       ELSE
		  l_install_to := v_install_rec.install_location_id;
	       END IF;

	       IF l_call_flag = 'Y' THEN
		  l_exists := 'N';
		  Begin
	   	     select 'Y'
	             into l_exists
	             from CSI_ITEM_INSTANCES
		     where instance_id = v_install_rec.instance_id
		     and   nvl(install_location_id,-999) = l_install_to;
                  Exception
                     when no_data_found then
                        l_exists := 'N';
		  End;
                  --
                  -- srramakr Bug # 3531056
                  -- If the child instance also belongs to the same system then the install location
                  -- would have got cascaded from the parent. So, there is no need to change this again.
                  --
                  IF l_exists = 'Y' THEN
                     csi_gen_utility_pvt.put_line('Install Location for instance '||to_char(v_install_rec.instance_id)||' already changed..');
                     Raise Process_next;
                  END IF;
                  --
		  l_instance_rec.instance_id           := v_install_rec.instance_id;
		  l_instance_rec.object_version_number := v_install_rec.object_version_number;
		  l_instance_rec.install_location_id   := l_install_to; --p_system_rec.install_site_use_id;

		  csi_item_instance_pvt.update_Item_Instance
		  (
		    p_api_version         => p_api_version
		   ,p_commit              => fnd_api.g_false
		   ,p_init_msg_list       => p_init_msg_list
		   ,p_validation_level    => p_validation_level
		   ,p_instance_rec        => l_instance_rec
		   ,p_txn_rec             => p_txn_rec
		   ,x_instance_id_lst     => l_instance_id_lst
		   ,x_return_status       => x_return_status
		   ,x_msg_count           => x_msg_count
		   ,x_msg_data            => x_msg_data
		   ,p_item_attribute_tbl  => l_item_attribute_tbl
		   ,p_location_tbl        => l_location_tbl
		   ,p_generic_id_tbl      => l_generic_id_tbl
		   ,p_lookup_tbl          => l_lookup_tbl
		   ,p_ins_count_rec       => l_ins_count_rec
                   ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
                   ,p_child_inst_tbl      => px_child_inst_tbl
		   );
		  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) Then
		     csi_gen_utility_pvt.put_line('Error from csi_item_instance_pvt.update_item_instance while updating Install Location.');
		     l_msg_index := 1;
		     l_msg_count := x_msg_count;
		     While l_msg_count > 0
			Loop
			  x_msg_data := FND_MSG_PUB.GET
			    ( l_msg_index,
			      FND_API.G_FALSE );
			      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			    l_msg_index := l_msg_index + 1;
			    l_msg_count := l_msg_count - 1;
			End Loop;
		     Raise FND_API.G_EXC_ERROR;
		  End If;
	       End If;
            Exception
               when Process_next then
                  null;
            End;
         End Loop;
      End If;
      --
      -- srramakr Bug # 2368440. When Bill_to or Ship_to address is changed, it should cascade to
      -- instances. The change will take place for the Owner Party Account with the same addresses.
      -- srramakr Bug 3621181 No need to cascade the addresses if ownership xfer occured.
      IF l_xfer_flag <> 'Y' THEN
	 IF ( (((nvl(p_system_rec.bill_to_site_use_id,-999) <> fnd_api.g_miss_num) AND
	      (nvl(p_system_rec.bill_to_site_use_id,-999) <> nvl(l_sys_csr.bill_to_site_use_id,-999))) OR
	      ((nvl(p_system_rec.ship_to_site_use_id,-999) <> fnd_api.g_miss_num) AND
	       (nvl(p_system_rec.ship_to_site_use_id,-999) <> nvl(l_sys_csr.ship_to_site_use_id,-999)))) AND
	      ((nvl(p_system_rec.BILL_TO_SITE_CHANGE_FLAG,'N') = 'Y') OR
	       (nvl(p_system_rec.SHIP_TO_SITE_CHANGE_FLAG,'N') = 'Y')) ) THEN
	    For v_rec in ip_acct_csr(l_sys_csr.bill_to_site_use_id,l_sys_csr.ship_to_site_use_id)
	    Loop
	       l_party_account_tbl := l_init_party_account_tbl;
	       l_call_flag := 'N';
	       IF nvl(v_rec.bill_to_address,-999) = nvl(l_sys_csr.bill_to_site_use_id,-999) THEN
		  IF p_system_rec.bill_to_site_use_id = FND_API.G_MISS_NUM OR
		     nvl(p_system_rec.BILL_TO_SITE_CHANGE_FLAG,'N') <> 'Y' THEN
		     l_bill_to := v_rec.bill_to_address;
		  ELSE
		     l_bill_to := p_system_rec.bill_to_site_use_id;
		     l_call_flag := 'Y';
		  END IF;
	       ELSE
		  l_bill_to := v_rec.bill_to_address;
	       END IF;
	       --
	       IF nvl(v_rec.ship_to_address,-999) = nvl(l_sys_csr.ship_to_site_use_id,-999) THEN
		  IF p_system_rec.ship_to_site_use_id = FND_API.G_MISS_NUM OR
		     nvl(p_system_rec.SHIP_TO_SITE_CHANGE_FLAG,'N') <> 'Y' THEN
		     l_ship_to := v_rec.ship_to_address;
		  ELSE
		     l_ship_to := p_system_rec.ship_to_site_use_id;
		     l_call_flag := 'Y';
		  END IF;
	       ELSE
		  l_ship_to := v_rec.ship_to_address;
	       END IF;
	       --
	       IF l_call_flag = 'Y' THEN
		  l_party_account_tbl(1).ip_account_id := v_rec.ip_account_id;
		  l_party_account_tbl(1).object_version_number := v_rec.object_version_number;
		  l_party_account_tbl(1).bill_to_address := l_bill_to;
		  l_party_account_tbl(1).ship_to_address := l_ship_to;
		 --
		 -- Call Update_Inst_party_account
		  csi_party_relationships_pvt.update_inst_party_account
			      (    p_api_version         => p_api_version
				  ,p_commit              => fnd_api.g_false
				  ,p_init_msg_list       => p_init_msg_list
				  ,p_validation_level    => p_validation_level
				  ,p_party_account_rec   => l_party_account_tbl(1)
				  ,p_txn_rec             => p_txn_rec
                                  ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
				  ,x_return_status       => x_return_status
				  ,x_msg_count           => x_msg_count
				  ,x_msg_data            => x_msg_data
			      );
		  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		    csi_gen_utility_pvt.put_line('Error from while updating Accounts.');
		    l_msg_index := 1;
		    l_msg_count := x_msg_count;
		    WHILE l_msg_count > 0
		    LOOP
		       x_msg_data := FND_MSG_PUB.GET
				      ( l_msg_index,
					 FND_API.G_FALSE );
		       csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		       l_msg_index := l_msg_index + 1;
		       l_msg_count := l_msg_count - 1;
		    END LOOP;
		    RAISE FND_API.G_EXC_ERROR;
		  END IF;
	       END IF;
		 --
	    End Loop;
	 END IF;
      END IF; -- l_xfer_flag check
	 --
      -- Updating the contact information
      IF (nvl(p_system_rec.BILL_TO_CONT_CHANGE_FLAG,'N') = 'Y' OR
         nvl(p_system_rec.SHIP_TO_CONT_CHANGE_FLAG,'N') = 'Y' OR
         nvl(p_system_rec.TECH_CONT_CHANGE_FLAG,'N') = 'Y' OR
         nvl(p_system_rec.SERV_ADMIN_CONT_CHANGE_FLAG,'N') = 'Y') THEN
         For party_rec in ins_party_csr
         Loop
            For cont_rec in contact_ip_csr(party_rec.instance_party_id)
            Loop
               l_party_tbl := l_init_party_tbl;
               l_call_flag := 'N';
               IF cont_rec.relationship_type_code = 'BILL_TO' AND
                  nvl(cont_rec.party_id,-999) = nvl(l_sys_csr.bill_to_contact_id,-999) THEN
                  IF p_system_rec.bill_to_contact_id = FND_API.G_MISS_NUM OR
                     p_system_rec.bill_to_contact_id IS NULL OR
                     nvl(p_system_rec.bill_to_cont_change_flag,'N') <> 'Y' THEN
                     l_contact_party_id := cont_rec.party_id;
                  ELSE
                     l_contact_party_id := p_system_rec.bill_to_contact_id;
                     l_call_flag := 'Y';
                  END IF;
               END IF; -- End of Bill To
               --
               IF cont_rec.relationship_type_code = 'SHIP_TO' AND
                  nvl(cont_rec.party_id,-999) = nvl(l_sys_csr.ship_to_contact_id,-999) THEN
                  IF p_system_rec.ship_to_contact_id = FND_API.G_MISS_NUM OR
                     p_system_rec.ship_to_contact_id IS NULL OR
                     nvl(p_system_rec.ship_to_cont_change_flag,'N') <> 'Y' THEN
                     l_contact_party_id := cont_rec.party_id;
                  ELSE
                     l_contact_party_id := p_system_rec.ship_to_contact_id;
                     l_call_flag := 'Y';
                  END IF;
               END IF; -- End of Ship To
               --
               IF cont_rec.relationship_type_code = 'TECHNICAL' AND
                  nvl(cont_rec.party_id,-999) = nvl(l_sys_csr.technical_contact_id,-999) THEN
                  IF p_system_rec.technical_contact_id = FND_API.G_MISS_NUM OR
                     p_system_rec.technical_contact_id IS NULL OR
                     nvl(p_system_rec.tech_cont_change_flag,'N') <> 'Y' THEN
                     l_contact_party_id := cont_rec.party_id;
                  ELSE
                     l_contact_party_id := p_system_rec.technical_contact_id;
                     l_call_flag := 'Y';
                  END IF;
               END IF; -- End of Technical
               --
               IF cont_rec.relationship_type_code = 'SERV_ADMIN' AND
                  nvl(cont_rec.party_id,-999) = nvl(l_sys_csr.service_admin_contact_id,-999) THEN
                  IF p_system_rec.service_admin_contact_id = FND_API.G_MISS_NUM OR
                     p_system_rec.service_admin_contact_id IS NULL OR
                     nvl(p_system_rec.serv_admin_cont_change_flag,'N') <> 'Y' THEN
                     l_contact_party_id := cont_rec.party_id;
                  ELSE
                     l_contact_party_id := p_system_rec.service_admin_contact_id;
                     l_call_flag := 'Y';
                  END IF;
               END IF; -- End of Service Admin
               -- Build the Party_tbl and call Update_inst_party_relationship API
               IF l_call_flag = 'Y' THEN
		  l_party_tbl(1).instance_party_id := cont_rec.instance_party_id;
		  l_party_tbl(1).object_version_number := cont_rec.object_version_number;
		  l_party_tbl(1).party_id := l_contact_party_id;
		  --
		  csi_party_relationships_pvt.update_inst_party_relationship
		      (p_api_version      => p_api_version
		      ,p_commit           => fnd_api.g_false
		      ,p_init_msg_list    => p_init_msg_list
		      ,p_validation_level => p_validation_level
		      ,p_party_rec        => l_party_tbl(1)
		      ,p_txn_rec          => p_txn_rec
		      ,x_return_status    => x_return_status
		      ,x_msg_count        => x_msg_count
		      ,x_msg_data         => x_msg_data
			);

		 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		      csi_gen_utility_pvt.put_line('Error from CSI_PARTY_RELATIONSHIPS_PVT.. ');
		      l_msg_index := 1;
		      l_msg_count := x_msg_count;
		     WHILE l_msg_count > 0
			LOOP
			   x_msg_data := FND_MSG_PUB.GET
					  ( l_msg_index,
					    FND_API.G_FALSE );
			    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			    l_msg_index := l_msg_index + 1;
			    l_msg_count := l_msg_count - 1;
			 END LOOP;
			 RAISE FND_API.G_EXC_ERROR;
		 END IF;
	       END IF; -- End of call_flag check
		 --
            End Loop;
         End Loop;
      END IF;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
        END IF;
      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      END IF;
      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO update_system_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO update_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO update_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END update_system;

PROCEDURE expire_system
 (
     p_api_version                 IN     NUMBER,
     p_commit                      IN     VARCHAR2,
     p_init_msg_list               IN     VARCHAR2,
     p_validation_level            IN     NUMBER,
     p_system_rec                  IN     csi_datastructures_pub.system_rec,
     p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY    csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY    VARCHAR2,
     x_msg_count                   OUT NOCOPY    NUMBER,
     x_msg_data                    OUT NOCOPY    VARCHAR2
 ) IS
 CURSOR  systems_csr (p_system_id NUMBER) IS
     SELECT system_id,
            customer_id,
            system_type_code,
            system_number,
            parent_system_id,
            ship_to_contact_id,
            bill_to_contact_id,
            technical_contact_id,
            service_admin_contact_id,
            ship_to_site_use_id,
            bill_to_site_use_id,
            install_site_use_id,
            coterminate_day_month,
            start_date_active,
            end_date_active,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            object_version_number,
		  operating_unit_id
     FROM   csi_systems_b
     WHERE  system_id=p_system_id
     FOR UPDATE OF object_version_number ;

CURSOR  tl_csr (sys_id NUMBER) IS
    SELECT name,
           description
    FROM   csi_systems_tl
    WHERE  system_id=sys_id
    FOR UPDATE OF system_id;


CURSOR expire_instance_csr(p_system_id  NUMBER) IS
       SELECT *
       FROM   csi_item_instances
       WHERE  system_id=p_system_id
       AND   sysdate BETWEEN NVL(active_start_date,(sysdate -1))
                 AND     NVL(active_end_date,(sysdate +1));

l_sys_csr                          systems_csr%ROWTYPE;
l_tl_csr                           tl_csr%ROWTYPE;
l_sysdate                          DATE     :=SYSDATE;
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_api_name                CONSTANT VARCHAR2(30) := 'expire_system';
l_system_rec                       csi_datastructures_pub.system_rec;
l_old_systems_rec                  csi_datastructures_pub.system_rec;
l_new_systems_rec                  csi_datastructures_pub.system_rec;
l_instance_rec                     csi_datastructures_pub.instance_rec;
l_init_instance_rec                csi_datastructures_pub.instance_rec;
l_debug_level                      NUMBER;
l_ext_attrib_values_tbl            csi_datastructures_pub.extend_attrib_values_tbl;
l_party_tbl                        csi_datastructures_pub.party_tbl;
l_account_tbl                      csi_datastructures_pub.party_account_tbl;
l_pricing_attrib_tbl               csi_datastructures_pub.pricing_attribs_tbl;
l_org_assignments_tbl              csi_datastructures_pub.organization_units_tbl;
l_asset_assignment_tbl             csi_datastructures_pub.instance_asset_tbl;
l_exists                           VARCHAR2(1);
--
Process_next                       EXCEPTION;

 BEGIN

      -- standard start of api savepoint
      SAVEPOINT expire_system_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        IF (l_debug_level > 0) THEN
          csi_gen_utility_pvt.put_line( 'expire_system');
        END IF;

        IF (l_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_Commit                  ||'-'||
                                p_Init_Msg_list           ||'-'||
                                p_Validation_level
                                );
            csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
            csi_gen_utility_pvt.dump_sys_rec(p_system_rec);
        END IF;

      OPEN systems_csr (p_system_rec.system_id);
      FETCH systems_csr INTO l_sys_csr;
       IF ( (l_sys_csr.object_version_number<>p_system_rec.object_version_number)
         AND (p_system_rec.object_version_number <> fnd_api.g_miss_num) ) THEN
         fnd_message.set_name('CSI', 'CSI_RECORD_CHANGED');
          fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
       END IF;
      CLOSE systems_csr;

      OPEN tl_csr (p_system_rec.system_id);
      FETCH tl_csr INTO l_tl_csr;
      CLOSE tl_csr;

       validate_system_id(
                p_init_msg_list          => fnd_api.g_false,
                p_validation_mode        => 'EXPIRE',
                p_system_id              => p_system_rec.system_id,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data);

        validate_object_version_num(
                p_init_msg_list          => fnd_api.g_false,
                p_validation_mode        => 'EXPIRE',
                p_object_version_number  => p_system_rec.object_version_number,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data);

       csi_gen_utility_pvt.put_line('Inside Expire System');
       IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
       END IF;

       IF    p_system_rec.end_date_active IS NOT NULL
         AND p_system_rec.end_date_active <> FND_API.G_MISS_DATE
       THEN
        l_sysdate := p_system_rec.end_date_active;
       END IF;
       -- srramakr Bug # 3031086. Moving the Update Table handler after cascading the changes to instances.
       -- This is because, as a part of bug # 2783027, we enforced system_id validation to make sure that
       -- no update is allowed on an instance that is attachaed to an expired system.
       -- In this case, if the system is already expired then cascade can't be done.
       --
       csi_transactions_pvt.create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_success_if_exists_flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_TXN');
              fnd_message.set_token('transaction_id',p_txn_rec.transaction_id );
              fnd_msg_pub.add;

              RAISE fnd_api.g_exc_error;
              RETURN;
         END IF;
	    -- srramakr Bug # 2230262. Expire_Item_Instance was called for updating the Active_end_Date
	    -- for the instances irrespective of whether the passed active_end_date is > sysdate or
	    -- <= sysdate. Changed this to call Update_Item_Instance which takes care of changing the
	    -- status to EXPIRED when the active_end_Date is <= sysdate. For active_end_date > sysdate,
	    -- only the date component should change for the instances and status should remain as it is.
	    --
         IF NVL(fnd_profile.value('CSI_CASCADE_SYS_TERMINATE'),'N')='Y' THEN

            FOR expire_csr IN expire_instance_csr(p_system_rec.system_id)
            LOOP
               Begin
                  l_exists := 'N';
                  Begin
                     select 'Y'
                     into l_exists
                     from CSI_ITEM_INSTANCES
                     where instance_id = expire_csr.instance_id
                     and   nvl(active_end_date,(sysdate+1)) <= sysdate;
                  Exception
                     when no_data_found then
                        l_exists := 'N';
                  End;
                  --
                  -- srramakr Bug # 3531056
                  -- If the child instance also belongs to the same system then it would have got
                  -- terminated when its parent got terminated. So, there is no need terminate it again.
                  IF l_exists = 'Y' THEN
                     csi_gen_utility_pvt.put_line('Instance '||to_char(expire_csr.instance_id)||'  Already expired');
                     Raise Process_next;
                  END IF;
                  --
		  l_instance_rec := l_init_instance_rec;  -- srramakr need to be initialized everytime.
		  l_ext_attrib_values_tbl.DELETE;
		  l_party_tbl.DELETE;
		  l_account_tbl.DELETE;
		  l_pricing_attrib_tbl.DELETE;
		  l_org_assignments_tbl.DELETE;
		  l_asset_assignment_tbl.DELETE;
		  l_instance_rec.instance_id := expire_csr.instance_id;
		  l_instance_rec.active_end_date := l_sysdate;-- modified by sguthiva for bug 2401398 p_system_rec.end_date_active;
		  l_instance_rec.object_version_number := expire_csr.object_version_number;
		  --
		  csi_gen_utility_pvt.put_line('Calling Update for instance_id '||to_char(l_instance_rec.instance_id));
		  csi_item_instance_pub.update_item_instance
		     (
		       p_api_version      => p_api_version
		       ,p_commit           => fnd_api.g_false
		       ,p_init_msg_list    => p_init_msg_list
		       ,p_validation_level => p_validation_level
		       ,p_instance_rec     => l_instance_rec
		       ,p_ext_attrib_values_tbl => l_ext_attrib_values_tbl
		       ,p_party_tbl        => l_party_tbl
		       ,p_account_tbl      => l_account_tbl
		       ,p_pricing_attrib_tbl => l_pricing_attrib_tbl
		       ,p_org_assignments_tbl => l_org_assignments_tbl
		       ,p_asset_assignment_tbl => l_asset_assignment_tbl
		       ,p_txn_rec          => p_txn_rec
		       ,x_instance_id_lst  => x_instance_id_lst
		       ,x_return_status    => x_return_status
		       ,x_msg_count        => x_msg_count
		       ,x_msg_data         => x_msg_data
		     );
		  IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
		     fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
		     fnd_message.set_token('instance_id',expire_csr.instance_id);
		     fnd_msg_pub.add;
		     RAISE fnd_api.g_exc_error;
		     RETURN;
		  END IF;
               Exception
                  when Process_next then
                     null;
               End;
            END LOOP; -- Instance loop
         END IF; -- cascade profile check
         --
         -- Moved down for Bug # 3031086.
         csi_systems_b_pkg.update_row(
                    p_system_id                   =>  p_system_rec.system_id,
                    p_customer_id                 =>  p_system_rec.customer_id,
                    p_system_type_code            =>  p_system_rec.system_type_code,
                    p_system_number               =>  p_system_rec.system_number,
                    p_parent_system_id            =>  p_system_rec.parent_system_id,
                    p_ship_to_contact_id          =>  p_system_rec.ship_to_contact_id,
                    p_bill_to_contact_id          =>  p_system_rec.bill_to_contact_id,
                    p_technical_contact_id        =>  p_system_rec.technical_contact_id,
                    p_service_admin_contact_id    =>  p_system_rec.service_admin_contact_id,
                    p_ship_to_site_use_id         =>  p_system_rec.ship_to_site_use_id,
                    p_bill_to_site_use_id         =>  p_system_rec.bill_to_site_use_id,
                    p_install_site_use_id         =>  p_system_rec.install_site_use_id,
                    p_coterminate_day_month       =>  p_system_rec.coterminate_day_month,
                    p_autocreated_from_system_id  =>  p_system_rec.autocreated_from_system_id,
                    p_start_date_active           =>  p_system_rec.start_date_active,
                    p_end_date_active             =>  l_sysdate,
                    p_context                     =>  p_system_rec.context,
                    p_attribute1                  =>  p_system_rec.attribute1,
                    p_attribute2                  =>  p_system_rec.attribute2,
                    p_attribute3                  =>  p_system_rec.attribute3,
                    p_attribute4                  =>  p_system_rec.attribute4,
                    p_attribute5                  =>  p_system_rec.attribute5,
                    p_attribute6                  =>  p_system_rec.attribute6,
                    p_attribute7                  =>  p_system_rec.attribute7,
                    p_attribute8                  =>  p_system_rec.attribute8,
                    p_attribute9                  =>  p_system_rec.attribute9,
                    p_attribute10                 =>  p_system_rec.attribute10,
                    p_attribute11                 =>  p_system_rec.attribute11,
                    p_attribute12                 =>  p_system_rec.attribute12,
                    p_attribute13                 =>  p_system_rec.attribute13,
                    p_attribute14                 =>  p_system_rec.attribute14,
                    p_attribute15                 =>  p_system_rec.attribute15,
                    p_created_by                  =>  fnd_api.g_miss_num,
                    p_creation_date               =>  fnd_api.g_miss_date,
                    p_last_updated_by             =>  fnd_global.user_id,
                    p_last_update_date            =>  SYSDATE,
                    p_last_update_login           =>  fnd_global.conc_login_id,
                    p_object_version_number       =>  fnd_api.g_miss_num,
                    p_name                        =>  p_system_rec.name,
                    p_description                 =>  p_system_rec.description,
                    p_operating_unit_id           =>  p_system_rec.operating_unit_id,
                    p_request_id                  =>  p_system_rec.request_id,
                    p_program_application_id      =>  p_system_rec.program_application_id,
                    p_program_id                  =>  p_system_rec.program_id,
                    p_program_update_date         =>  p_system_rec.program_update_date);

            l_old_systems_rec.system_id:=l_sys_csr.system_id;
            l_old_systems_rec.customer_id:=l_sys_csr.customer_id;
            l_old_systems_rec.system_type_code:=l_sys_csr.system_type_code;
            l_old_systems_rec.system_number:=l_sys_csr.system_number;
            l_old_systems_rec.parent_system_id:=l_sys_csr.parent_system_id;
            l_old_systems_rec.ship_to_contact_id:=l_sys_csr.ship_to_contact_id;
            l_old_systems_rec.bill_to_contact_id:=l_sys_csr.bill_to_contact_id;
            l_old_systems_rec.technical_contact_id:=l_sys_csr.technical_contact_id;
            l_old_systems_rec.service_admin_contact_id:=l_sys_csr.service_admin_contact_id;
            l_old_systems_rec.ship_to_site_use_id:=l_sys_csr.ship_to_site_use_id;
            l_old_systems_rec.bill_to_site_use_id:=l_sys_csr.bill_to_site_use_id;
            l_old_systems_rec.install_site_use_id:=l_sys_csr.install_site_use_id;
            l_old_systems_rec.coterminate_day_month:=l_sys_csr.coterminate_day_month;
            l_old_systems_rec.start_date_active:=l_sys_csr.start_date_active;
            l_old_systems_rec.end_date_active:=l_sys_csr.end_date_active;
            l_old_systems_rec.context:=l_sys_csr.context;
            l_old_systems_rec.attribute1:=l_sys_csr.attribute1;
            l_old_systems_rec.attribute2:=l_sys_csr.attribute2;
            l_old_systems_rec.attribute3:=l_sys_csr.attribute3;
            l_old_systems_rec.attribute4:=l_sys_csr.attribute4;
            l_old_systems_rec.attribute5:=l_sys_csr.attribute5;
            l_old_systems_rec.attribute6:=l_sys_csr.attribute6;
            l_old_systems_rec.attribute7:=l_sys_csr.attribute7;
            l_old_systems_rec.attribute8:=l_sys_csr.attribute8;
            l_old_systems_rec.attribute9:=l_sys_csr.attribute9;
            l_old_systems_rec.attribute10:=l_sys_csr.attribute10;
            l_old_systems_rec.attribute11:=l_sys_csr.attribute11;
            l_old_systems_rec.attribute12:=l_sys_csr.attribute12;
            l_old_systems_rec.attribute13:=l_sys_csr.attribute13;
            l_old_systems_rec.attribute14:=l_sys_csr.attribute14;
            l_old_systems_rec.attribute15:=l_sys_csr.attribute15;
            l_old_systems_rec.object_version_number:=l_sys_csr.object_version_number;
            l_old_systems_rec.name:=l_tl_csr.name;
            l_old_systems_rec.description:=l_tl_csr.description;
		  l_old_systems_rec.operating_unit_id := l_sys_csr.operating_unit_id;

            l_new_systems_rec := p_system_rec;

                validate_history(p_old_systems_rec  =>  l_old_systems_rec,
                                 p_new_systems_rec  =>  l_new_systems_rec,
                                 p_transaction_id   =>  p_txn_rec.transaction_id,
                                 p_flag             =>  'EXPIRE',
                                 p_sysdate          =>  l_sysdate,
                                 x_return_status    =>  x_return_status,
                                 x_msg_count        =>  x_msg_count,
                                 x_msg_data         =>  x_msg_data
                                 );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
        END IF;
      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO expire_system_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO expire_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO expire_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );



 END expire_system;


-- item-level validation procedures
PROCEDURE validate_system_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_system_id                  IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_system_id IS NOT NULL) AND (p_system_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_systems_b
                WHERE   system_id=p_system_id;
                  fnd_message.set_name('CSI', 'CSI_INVALID_SYSTEM_ID');
                  fnd_message.set_token('system_id',p_system_id);
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
                EXCEPTION
                WHEN no_data_found THEN
                  x_return_status := fnd_api.g_ret_sts_success;
                END;
         END IF;

       ELSIF p_validation_mode='UPDATE' OR  p_validation_mode='EXPIRE' THEN
         IF ( (p_system_id IS NOT NULL) AND (p_system_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_systems_b
                WHERE   system_id=p_system_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SYSTEM_ID');
                     fnd_message.set_token('system_id',p_system_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          ELSE
                     fnd_message.set_name('CSI', 'CSI_NO_SYSTEM_ID');
                     fnd_message.set_token('REQUIRED_PARAM','SYSTEM_ID');
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
          END IF;

       END IF;



      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_system_id;


PROCEDURE validate_customer_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_customer_id                IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_customer_id IS NOT NULL) AND (p_customer_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                  SELECT 'x'
                  INTO   l_dummy
                  FROM   hz_cust_accounts hzc
                        ,hz_parties hz
                  WHERE  hzc.cust_account_id = p_customer_id
                  AND    hzc.party_id=hz.party_id;

                 /*SELECT  'x'
                   INTO    l_dummy
                   FROM    hz_parties
                   WHERE   party_id=p_customer_id; */

                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_CUSTOMER_ID');
                     fnd_message.set_token('customer_id',p_customer_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          ELSE
                     fnd_message.set_name('CSI', 'CSI_CUST_ID_NOT_PASSED');
                     fnd_message.set_token('REQUIRED_PARAM','CUSTOMER_ID');
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;

          END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_customer_id IS NOT NULL) AND (p_customer_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                  SELECT 'x'
                  INTO   l_dummy
                  FROM   hz_cust_accounts hzc
                        ,hz_parties hz
                  WHERE  hzc.cust_account_id = p_customer_id
                  AND    hzc.party_id=hz.party_id;

                /* SELECT  'x'
                   INTO    l_dummy
                   FROM    hz_parties
                   WHERE   party_id=p_customer_id; */
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_CUSTOMER_ID');
                     fnd_message.set_token('customer_id',p_customer_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_customer_id;


PROCEDURE validate_system_type_code (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_system_type_code           IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
l_sys_lookup_type   VARCHAR2(30) := 'CSI_SYSTEM_TYPE';
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN

         IF ( (p_system_type_code IS NOT NULL) AND (p_system_type_code<>fnd_api.g_miss_char) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_lookups
                WHERE   lookup_type=l_sys_lookup_type
                AND     lookup_code=p_system_type_code;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SYS_TYPE_CODE');
                     fnd_message.set_token('system_type_code',p_system_type_code);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          ELSE
                     fnd_message.set_name('CSI', 'CSI_NO_SYS_TYPE_CODE');
                     fnd_message.set_token('REQUIRED_PARAM','SYSTEM_TYPE_CODE');

                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;

          END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_system_type_code IS NOT NULL) AND (p_system_type_code<>fnd_api.g_miss_char) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_lookups
                WHERE   lookup_type=l_sys_lookup_type
                AND     lookup_code=p_system_type_code;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SYS_TYPE_CODE');
                     fnd_message.set_token('system_type_code',p_system_type_code);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;


      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_system_type_code;




PROCEDURE validate_parent_system_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_parent_system_id           IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list IF p_init_msg_list IS set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_parent_system_id IS NOT NULL) AND (p_parent_system_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_systems_b
                WHERE   system_id=p_parent_system_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_PARENT_SYS_ID');
                     fnd_message.set_token('parent_system_id',p_parent_system_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;


       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_parent_system_id IS NOT NULL) AND (p_parent_system_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_systems_b
                WHERE   system_id=p_parent_system_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_PARENT_SYS_ID');
                     fnd_message.set_token('parent_system_id',p_parent_system_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_parent_system_id;


PROCEDURE validate_ship_to_contact_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_ship_to_contact_id         IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_ship_to_contact_id IS NOT NULL) AND (p_ship_to_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_ship_to_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SHIPTO_CT_ID');
                     fnd_message.set_token('ship_to_contact_id',p_ship_to_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;

         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_ship_to_contact_id IS NOT NULL) AND (p_ship_to_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_ship_to_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SHIPTO_CT_ID');
                     fnd_message.set_token('ship_to_contact_id',p_ship_to_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_ship_to_contact_id;


PROCEDURE validate_bill_to_contact_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_bill_to_contact_id         IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_bill_to_contact_id IS NOT NULL) AND (p_bill_to_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_bill_to_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_BILLTO_CT_ID');
                     fnd_message.set_token('bill_to_contact_id',p_bill_to_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_bill_to_contact_id IS NOT NULL) AND (p_bill_to_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_bill_to_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_BILLTO_CT_ID');
                     fnd_message.set_token('bill_to_contact_id',p_bill_to_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_bill_to_contact_id;


PROCEDURE validate_technical_contact_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_technical_contact_id       IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_technical_contact_id IS NOT NULL) AND (p_technical_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_technical_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_TECH_CT_ID');
                     fnd_message.set_token('technical_contact_id',p_technical_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_technical_contact_id IS NOT NULL) AND (p_technical_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_technical_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_TECH_CT_ID');
                     fnd_message.set_token('technical_contact_id',p_technical_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_technical_contact_id;


PROCEDURE validate_srv_admin_cont_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_service_admin_contact_id   IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_service_admin_contact_id IS NOT NULL) AND (p_service_admin_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_service_admin_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SRVADMIN_CT_ID');
                     fnd_message.set_token('service_admin_contact_id',p_service_admin_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_service_admin_contact_id IS NOT NULL) AND (p_service_admin_contact_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_parties
                WHERE   party_id=p_service_admin_contact_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SRVADMIN_CT_ID');
                     fnd_message.set_token('service_admin_contact_id',p_service_admin_contact_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_srv_admin_cont_id;


PROCEDURE validate_ship_to_site_use_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_ship_to_site_use_id        IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_ship_to_site_use_id IS NOT NULL) AND (p_ship_to_site_use_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_cust_site_uses_all--hz_party_sites
                WHERE   site_use_id = p_ship_to_site_use_id
                AND     site_use_code = 'SHIP_TO';
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SHIP_TO_ID');
                     fnd_message.set_token('ship_to_site_use_id',p_ship_to_site_use_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_ship_to_site_use_id IS NOT NULL) AND (p_ship_to_site_use_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_cust_site_uses_all --hz_party_sites
                WHERE   site_use_id = p_ship_to_site_use_id
                AND     site_use_code = 'SHIP_TO';
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_SHIP_TO_ID');
                     fnd_message.set_token('ship_to_site_use_id',p_ship_to_site_use_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_ship_to_site_use_id;


PROCEDURE validate_bill_to_site_use_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_bill_to_site_use_id        IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE' THEN
         IF ( (p_bill_to_site_use_id IS NOT NULL) AND (p_bill_to_site_use_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_cust_site_uses_all  --hz_cust_acct_sites_all
                WHERE   site_use_id = p_bill_to_site_use_id
                AND     site_use_code = 'BILL_TO';
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_BILL_TO_ID');
                     fnd_message.set_token('bill_to_site_use_id',p_bill_to_site_use_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_bill_to_site_use_id IS NOT NULL) AND (p_bill_to_site_use_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_cust_site_uses_all  --hz_cust_acct_sites_all
                WHERE   site_use_id = p_bill_to_site_use_id
                AND     site_use_code = 'BILL_TO';
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_BILL_TO_ID');
                     fnd_message.set_token('bill_to_site_use_id',p_bill_to_site_use_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;

       END IF;
            -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_bill_to_site_use_id;


PROCEDURE validate_install_site_use_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_install_site_use_id        IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN

      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
    IF p_validation_mode='CREATE' THEN
         IF ( (p_install_site_use_id IS NOT NULL) AND (p_install_site_use_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_party_sites
                WHERE   party_site_id=p_install_site_use_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_INSTALL_ID');
                     fnd_message.set_token('install_site_use_id',p_install_site_use_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
         END IF;
       ELSIF p_validation_mode='UPDATE' THEN
         IF ( (p_install_site_use_id IS NOT NULL) AND (p_install_site_use_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    hz_party_sites
                WHERE   party_site_id=p_install_site_use_id;
                EXCEPTION
                WHEN no_data_found THEN
                      fnd_message.set_name('CSI', 'CSI_INVALID_INSTALL_ID');
                     fnd_message.set_token('install_site_use_id',p_install_site_use_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_install_site_use_id;

PROCEDURE validate_auto_sys_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2  ,
    p_auto_sys_id                IN   NUMBER    ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN

      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      x_return_status := fnd_api.g_ret_sts_success;

    IF p_validation_mode='CREATE' THEN
         IF ( (p_auto_sys_id IS NOT NULL) AND (p_auto_sys_id<>fnd_api.g_miss_num) )
             THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_systems_b
                WHERE   system_id=p_auto_sys_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_AUTOSYS_ID');
                     fnd_message.set_token('autocreated_from_system_id',p_auto_sys_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
           END IF;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_auto_sys_id;

PROCEDURE validate_start_end_date (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2  ,
    p_system_id                  IN   NUMBER    ,
    p_start_date                 IN   DATE      ,
    p_end_date                   IN   DATE      ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_start_date_active             DATE;
BEGIN

      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      x_return_status := fnd_api.g_ret_sts_success;

    IF p_validation_mode='CREATE' THEN
         IF    ( (p_start_date IS NOT NULL) AND (p_start_date<>fnd_api.g_miss_date) )
           AND ( (p_end_date IS NOT NULL) AND (p_end_date<>fnd_api.g_miss_date) )
             THEN
                IF (p_start_date > p_end_date)
                THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_START_DATE');
                     fnd_message.set_token('START_DATE_ACTIVE',p_start_date);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END IF;
         ELSIF ( (p_start_date IS NULL) OR (p_start_date = fnd_api.g_miss_date) )
           AND ( (p_end_date IS NOT NULL) AND (p_end_date<>fnd_api.g_miss_date) )
         THEN
              fnd_message.set_name('CSI', 'CSI_INVALID_END_DATE');
              fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
              fnd_msg_pub.add;
              x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;

      IF p_validation_mode='UPDATE' THEN
         IF    ( (p_start_date IS NOT NULL) AND (p_start_date<>fnd_api.g_miss_date) )
           AND ( (p_end_date IS NOT NULL) AND (p_end_date<>fnd_api.g_miss_date) )
             THEN
                IF (p_start_date > p_end_date)
                THEN
                     fnd_message.set_name('CSI', 'CSI_START_DATE_GREATER');
                     fnd_message.set_token('START_DATE_ACTIVE',p_start_date);
                     fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END IF;
         ELSIF ( (p_start_date IS NULL) OR (p_start_date = fnd_api.g_miss_date) )
           AND ( (p_end_date IS NOT NULL) AND (p_end_date<>fnd_api.g_miss_date) )
         THEN
              BEGIN
                 SELECT  start_date_active
                 INTO    l_start_date_active
                 FROM    csi_systems_b
                 WHERE   system_id = p_system_id;
                 IF l_start_date_active > p_end_date
                 THEN
                     fnd_message.set_name('CSI', 'CSI_START_DATE_GREATER');
                     fnd_message.set_token('START_DATE_ACTIVE',l_start_date_active);
                     fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                 END IF;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_END_DATE');
                     fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
              END;
         END IF;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_start_end_date;



PROCEDURE validate_name (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_name                       IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF p_validation_mode='CREATE'  THEN
         IF ( (p_name IS NULL) OR (p_name=fnd_api.g_miss_char) ) THEN
            IF (fnd_profile.value('CSI_AUTO_GEN_SYS_NAME') = 'Y')
            THEN
              NULL;
            ELSE
                     fnd_message.set_name('CSI', 'CSI_SYS_NAME_NOT_PASSED');
                     fnd_message.set_token('REQUIRED_PARAM','SYSTEM_NAME');
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF;
      END IF;

      IF p_validation_mode='UPDATE' THEN
         IF ( (p_name IS NULL) OR (p_name=fnd_api.g_miss_char) ) THEN
                     fnd_message.set_name('CSI', 'CSI_SYS_NAME_NOT_PASSED');
                     fnd_message.set_token('REQUIRED_PARAM','SYSTEM_NAME');
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;


      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_name;


PROCEDURE validate_object_version_num (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_object_version_number      IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN

      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column


       IF ( (p_validation_mode = 'UPDATE') OR (p_validation_mode = 'EXPIRE') ) THEN
          IF ( (p_object_version_number IS NULL) OR (p_object_version_number = fnd_api.g_miss_num) ) THEN
             fnd_message.set_name('CSI', 'CSI_MISSING_OBJ_VER_NUM');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_object_version_num;




PROCEDURE validate_systems(
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_validation_mode            IN   VARCHAR2,
    p_system_rec                 IN   csi_datastructures_pub.system_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'validate_systems';
 BEGIN

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

-- The following IF statement has been commented out for Bug: 3271806
--      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN

          validate_customer_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_customer_id            => p_system_rec.customer_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_system_type_code(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_system_type_code       => p_system_rec.system_type_code,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_parent_system_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_parent_system_id       => p_system_rec.parent_system_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_ship_to_contact_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_ship_to_contact_id     => p_system_rec.ship_to_contact_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_bill_to_contact_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_bill_to_contact_id     => p_system_rec.bill_to_contact_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_technical_contact_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_technical_contact_id   => p_system_rec.technical_contact_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_srv_admin_cont_id(
              p_init_msg_list              => fnd_api.g_false,
              p_validation_mode            => p_validation_mode,
              p_service_admin_contact_id   => p_system_rec.service_admin_contact_id,
              x_return_status              => x_return_status,
              x_msg_count                  => x_msg_count,
              x_msg_data                   => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_ship_to_site_use_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_ship_to_site_use_id    => p_system_rec.ship_to_site_use_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_bill_to_site_use_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_bill_to_site_use_id    => p_system_rec.bill_to_site_use_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_install_site_use_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_install_site_use_id    => p_system_rec.install_site_use_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

           validate_name(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_name                   => p_system_rec.name,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

  --      END IF;
END validate_systems;
--
 PROCEDURE Get_System_Details
 (
     p_api_version               IN  NUMBER  ,
     p_commit                    IN  VARCHAR2,
     p_init_msg_list             IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     p_system_query_rec          IN  csi_datastructures_pub.system_query_rec,
     p_time_stamp                IN  DATE,
     p_active_systems_only       IN  VARCHAR2,
     x_system_header_tbl         OUT NOCOPY csi_datastructures_pub.system_header_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 )
 IS

l_api_name                 CONSTANT VARCHAR2(30)    := 'get_system_details';
l_api_version              CONSTANT NUMBER          := 1.0;
l_return_status_full                VARCHAR2(1);
l_crit_systems_rec                  csi_datastructures_pub.system_query_rec := p_system_query_rec;
l_systems_where                     VARCHAR2(2000)  := '';
l_cur_get_systems                   NUMBER;
l_select_cl                         VARCHAR2(2000)  := '';
l_def_systems_rec                   csi_datastructures_pub.system_rec;
l_ignore                            NUMBER;
l_return_tot_count                  VARCHAR2(1)     := fnd_api.g_false;
l_returned_rec_count                NUMBER          := 0;
l_sys_rec                           csi_datastructures_pub.system_rec;
l_tot_rec_count                     NUMBER          := 0;
l_start_rec_prt                     NUMBER          :=1;
l_rec_requested                     NUMBER          :=1000000;
l_new_rec                           csi_datastructures_pub.system_rec;
l_flag                              VARCHAR2(4);
l_active_systems_only               VARCHAR2(1):= p_active_systems_only;
l_debug_level                       NUMBER;
l_systems_tbl                       csi_datastructures_pub.systems_tbl;
l_sys_hdr_count                     NUMBER := 0;
l_last_purge_date                   DATE;
--
Process_next                        EXCEPTION;
BEGIN

      -- standard start of api savepoint
      SAVEPOINT get_systems_details;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;




      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        IF (l_debug_level > 0) THEN
          csi_gen_utility_pvt.put_line( 'get_system_details');
        END IF;

        IF (l_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_Commit                  ||'-'||
                                p_Init_Msg_list           ||'-'||
                                p_Validation_level        ||'-'||
                                p_time_stamp              ||'-'||
                                p_active_systems_only
                                );
            csi_gen_utility_pvt.dump_sys_query_rec(p_system_query_rec);
        END IF;

      IF
      ( ((p_system_query_rec.system_id IS NULL)         OR (p_system_query_rec.system_id = fnd_api.g_miss_num))
    AND ((p_system_query_rec.system_type_code IS NULL)  OR (p_system_query_rec.system_type_code = fnd_api.g_miss_char))
    AND ((p_system_query_rec.system_number IS NULL)     OR (p_system_query_rec.system_number  = fnd_api.g_miss_char))
      )
      THEN
       fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       RAISE fnd_api.g_exc_error;
      END IF;

      gen_select(l_crit_systems_rec,l_select_cl);


      gen_systems_where(l_crit_systems_rec,l_active_systems_only, l_systems_where);
          IF dbms_sql.is_open(l_cur_get_systems) THEN
          dbms_sql.close_CURSOR(l_cur_get_systems);
          END IF;

       l_cur_get_systems := dbms_sql.open_CURSOR;

       dbms_sql.parse(l_cur_get_systems, l_select_cl||l_systems_where , dbms_sql.native);

       bind(l_crit_systems_rec, l_cur_get_systems);

       define_columns(l_def_systems_rec, l_cur_get_systems);

       l_ignore := dbms_sql.execute(l_cur_get_systems);
     --
     -- Get the last purge date from csi_item_instances table
     --
     BEGIN
       SELECT last_purge_date
       INTO   l_last_purge_date
       FROM   CSI_ITEM_INSTANCES
       WHERE  rownum < 2;
     EXCEPTION
       WHEN no_data_found THEN
         NULL;
       WHEN others THEN
         NULL;
     END;
     --
     LOOP
     IF((dbms_sql.fetch_rows(l_cur_get_systems)>0) AND ( (l_returned_rec_count<l_rec_requested) OR (l_rec_requested=fnd_api.g_miss_num)))
      THEN

             get_column_values(l_cur_get_systems, l_sys_rec);

              l_tot_rec_count := l_tot_rec_count + 1 ;

              IF  (l_returned_rec_count < l_rec_requested)
              THEN
                   l_returned_rec_count := l_returned_rec_count + 1;
                   IF ( (p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE) )
                   THEN
                       IF ( (l_last_purge_date IS NOT NULL) AND (p_time_stamp <= l_last_purge_date) )
                       THEN
                           csi_gen_utility_pvt.put_line('Warning! History for this entity has already been purged for the datetime stamp passed. ' ||
                           'Please provide a valid datetime stamp.');
                           FND_MESSAGE.Set_Name('CSI', 'CSI_API_HIST_AFTER_PURGE_REQ');
                           FND_MSG_PUB.ADD;
                       ELSE
                           get_history( p_sys_rec    => l_sys_rec
                                       ,p_new_rec    => l_new_rec
                                       ,p_flag       => l_flag
                                       ,p_time_stamp => p_time_stamp);
                               IF l_flag='ADD' THEN
                                  l_systems_tbl(l_returned_rec_count) :=l_new_rec;--l_sys_rec;
                               END IF;
                       END IF;
                   ELSE
                      l_systems_tbl(l_returned_rec_count) :=l_sys_rec;
                   END IF;
              END IF;
      ELSE
          EXIT;
      END IF;
      END LOOP;
      --
      -- END of api body
      --
     dbms_sql.close_cursor(l_cur_get_systems);
      --
      IF l_systems_tbl.count > 0 THEN
         FOR sys_row IN l_systems_tbl.FIRST .. l_systems_tbl.LAST
         LOOP
          BEGIN
            IF l_systems_tbl.EXISTS(sys_row) THEN
               -- Construct Systems Header Tbl using Systems Tbl
               -- Ignore the Expired Systems
               IF l_active_systems_only = 'T' THEN
                  IF l_systems_tbl(sys_row).end_date_active IS NOT NULL AND
                     l_systems_tbl(sys_row).end_date_active < SYSDATE THEN
                     RAISE Process_next;
                  END IF;
               END IF;
               l_sys_hdr_count := l_sys_hdr_count + 1;
               x_system_header_tbl(l_sys_hdr_count).system_id := l_systems_tbl(sys_row).system_id;
	       x_system_header_tbl(l_sys_hdr_count).operating_unit_id := l_systems_tbl(sys_row).operating_unit_id;
	       x_system_header_tbl(l_sys_hdr_count).customer_id := l_systems_tbl(sys_row).customer_id;
	       x_system_header_tbl(l_sys_hdr_count).system_type_code := l_systems_tbl(sys_row).system_type_code;
	       x_system_header_tbl(l_sys_hdr_count).system_number := l_systems_tbl(sys_row).system_number;
	       x_system_header_tbl(l_sys_hdr_count).parent_system_id := l_systems_tbl(sys_row).parent_system_id;
	       x_system_header_tbl(l_sys_hdr_count).technical_contact_id := l_systems_tbl(sys_row).technical_contact_id;
	       x_system_header_tbl(l_sys_hdr_count).service_admin_contact_id := l_systems_tbl(sys_row).service_admin_contact_id;
	       x_system_header_tbl(l_sys_hdr_count).install_site_use_id := l_systems_tbl(sys_row).install_site_use_id;
	       x_system_header_tbl(l_sys_hdr_count).bill_to_contact_id := l_systems_tbl(sys_row).bill_to_contact_id;
	       x_system_header_tbl(l_sys_hdr_count).bill_to_site_use_id := l_systems_tbl(sys_row).bill_to_site_use_id;
	       x_system_header_tbl(l_sys_hdr_count).ship_to_site_use_id := l_systems_tbl(sys_row).ship_to_site_use_id;
	       x_system_header_tbl(l_sys_hdr_count).ship_to_contact_id := l_systems_tbl(sys_row).ship_to_contact_id;
	       x_system_header_tbl(l_sys_hdr_count).coterminate_day_month := l_systems_tbl(sys_row).coterminate_day_month;
	       x_system_header_tbl(l_sys_hdr_count).start_date_active := l_systems_tbl(sys_row).start_date_active;
	       x_system_header_tbl(l_sys_hdr_count).end_date_active := l_systems_tbl(sys_row).end_date_active;
	       x_system_header_tbl(l_sys_hdr_count).autocreated_from_system_id := l_systems_tbl(sys_row).autocreated_from_system_id;
	       x_system_header_tbl(l_sys_hdr_count).attribute1 := l_systems_tbl(sys_row).attribute1;
	       x_system_header_tbl(l_sys_hdr_count).attribute2 := l_systems_tbl(sys_row).attribute2;
	       x_system_header_tbl(l_sys_hdr_count).attribute3 := l_systems_tbl(sys_row).attribute3;
	       x_system_header_tbl(l_sys_hdr_count).attribute4 := l_systems_tbl(sys_row).attribute4;
	       x_system_header_tbl(l_sys_hdr_count).attribute5 := l_systems_tbl(sys_row).attribute5;
	       x_system_header_tbl(l_sys_hdr_count).attribute6 := l_systems_tbl(sys_row).attribute6;
	       x_system_header_tbl(l_sys_hdr_count).attribute7 := l_systems_tbl(sys_row).attribute7;
	       x_system_header_tbl(l_sys_hdr_count).attribute8 := l_systems_tbl(sys_row).attribute8;
	       x_system_header_tbl(l_sys_hdr_count).attribute9 := l_systems_tbl(sys_row).attribute9;
	       x_system_header_tbl(l_sys_hdr_count).attribute10 := l_systems_tbl(sys_row).attribute10;
	       x_system_header_tbl(l_sys_hdr_count).attribute11 := l_systems_tbl(sys_row).attribute11;
	       x_system_header_tbl(l_sys_hdr_count).attribute12 := l_systems_tbl(sys_row).attribute12;
	       x_system_header_tbl(l_sys_hdr_count).attribute13 := l_systems_tbl(sys_row).attribute13;
	       x_system_header_tbl(l_sys_hdr_count).attribute14 := l_systems_tbl(sys_row).attribute14;
	       x_system_header_tbl(l_sys_hdr_count).attribute15 := l_systems_tbl(sys_row).attribute15;
	       x_system_header_tbl(l_sys_hdr_count).context := l_systems_tbl(sys_row).context;
	       x_system_header_tbl(l_sys_hdr_count).config_system_type := l_systems_tbl(sys_row).config_system_type;
	       x_system_header_tbl(l_sys_hdr_count).object_version_number := l_systems_tbl(sys_row).object_version_number;
            END IF;
          EXCEPTION
             WHEN Process_next THEN
                NULL;
          END;
         END LOOP;
         --
         csi_systems_pvt.Resolve_ID_Columns(p_system_header_tbl => x_system_header_tbl);
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
               ROLLBACK TO get_system_details;
               x_return_status := fnd_api.g_ret_sts_error ;
               fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO get_system_details;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                         (p_count => x_msg_count ,
                          p_data => x_msg_data
                         );

          WHEN OTHERS THEN
                ROLLBACK TO get_system_details;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                         (p_count => x_msg_count ,
                          p_data => x_msg_data
                         );

 END get_system_details;
 --
 PROCEDURE Resolve_ID_Columns
              (p_system_header_tbl IN OUT NOCOPY csi_datastructures_pub.system_header_tbl)
 IS
 --
   l_sys_type                VARCHAR2(30) := 'CSI_SYSTEM_TYPE';
 BEGIN
    IF p_system_header_tbl.count > 0 THEN
       FOR sys_row in p_system_header_tbl.FIRST .. p_system_header_tbl.LAST
       LOOP
          IF p_system_header_tbl.EXISTS(sys_row) THEN
             IF ( (p_system_header_tbl(sys_row).system_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).system_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT name
                         ,description
                   INTO p_system_header_tbl(sys_row).name
                       ,p_system_header_tbl(sys_row).description
                   FROM CSI_SYSTEMS_VL
                   WHERE system_id = p_system_header_tbl(sys_row).system_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).customer_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).customer_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hza.account_number
                         ,hza.account_name
                         ,hza.party_id
                         ,hzp.party_number
                         ,hzp.party_name
                   INTO p_system_header_tbl(sys_row).customer_number
                       ,p_system_header_tbl(sys_row).customer_name
                       ,p_system_header_tbl(sys_row).party_id
                       ,p_system_header_tbl(sys_row).customer_party_number
                       ,p_system_header_tbl(sys_row).party_name
                   FROM HZ_CUST_ACCOUNTS hza
                       ,HZ_PARTIES hzp
                   WHERE hza.cust_account_id = p_system_header_tbl(sys_row).customer_id
                   AND   hza.party_id = hzp.party_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).ship_to_site_use_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).ship_to_site_use_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_id
                         ,hzp.party_number
                         ,hzp.party_name
                         ,hzp.party_type
                         ,hls.address1
                         ,hls.address2
                         ,hls.address3
                         ,hls.address4
                         ,hls.city
                         ,hls.state
                         ,hls.postal_code
                         ,hls.country
                         ,hls.description
                         ,hls.location_id
                         ,hps.party_site_number
                   INTO p_system_header_tbl(sys_row).ship_to_customer_id
                       ,p_system_header_tbl(sys_row).ship_to_customer_number
                       ,p_system_header_tbl(sys_row).ship_to_customer
                       ,p_system_header_tbl(sys_row).ship_party_type
                       ,p_system_header_tbl(sys_row).ship_to_address1
                       ,p_system_header_tbl(sys_row).ship_to_address2
                       ,p_system_header_tbl(sys_row).ship_to_address3
                       ,p_system_header_tbl(sys_row).ship_to_address4
                       ,p_system_header_tbl(sys_row).ship_to_location
                       ,p_system_header_tbl(sys_row).ship_state
                       ,p_system_header_tbl(sys_row).ship_postal_code
                       ,p_system_header_tbl(sys_row).ship_country
                       ,p_system_header_tbl(sys_row).ship_description
                       ,p_system_header_tbl(sys_row).ship_to_location_id
                       ,p_system_header_tbl(sys_row).ship_to_site_number
                   FROM HZ_CUST_SITE_USES_ALL hzsu
                       ,HZ_CUST_ACCT_SITES_ALL hzca
                       ,HZ_PARTY_SITES hps
                       ,HZ_PARTIES hzp
                       ,HZ_LOCATIONS hls
                   WHERE hzsu.site_use_id = p_system_header_tbl(sys_row).ship_to_site_use_id
                   AND   hzca.cust_acct_site_id = hzsu.cust_acct_site_id
                   AND   hzca.party_site_id = hps.party_site_id
                   AND   hps.party_id = hzp.party_id
                   AND   hps.location_id = hls.location_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).bill_to_site_use_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).bill_to_site_use_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_id
                         ,hzp.party_number
                         ,hzp.party_name
                         ,hzp.party_type
                         ,hls.address1
                         ,hls.address2
                         ,hls.address3
                         ,hls.address4
                         ,hls.city
                         ,hls.state
                         ,hls.postal_code
                         ,hls.country
                         ,hls.description
                         ,hls.location_id
                         ,hps.party_site_number
                   INTO p_system_header_tbl(sys_row).bill_to_customer_id
                       ,p_system_header_tbl(sys_row).bill_to_customer_number
                       ,p_system_header_tbl(sys_row).bill_to_customer
                       ,p_system_header_tbl(sys_row).bill_party_type
                       ,p_system_header_tbl(sys_row).bill_to_address1
                       ,p_system_header_tbl(sys_row).bill_to_address2
                       ,p_system_header_tbl(sys_row).bill_to_address3
                       ,p_system_header_tbl(sys_row).bill_to_address4
                       ,p_system_header_tbl(sys_row).bill_to_location
                       ,p_system_header_tbl(sys_row).bill_state
                       ,p_system_header_tbl(sys_row).bill_postal_code
                       ,p_system_header_tbl(sys_row).bill_country
                       ,p_system_header_tbl(sys_row).bill_description
                       ,p_system_header_tbl(sys_row).bill_to_location_id
                       ,p_system_header_tbl(sys_row).bill_to_site_number
                   FROM HZ_CUST_SITE_USES_ALL hzsu
                       ,HZ_CUST_ACCT_SITES_ALL hzca
                       ,HZ_PARTY_SITES hps
                       ,HZ_PARTIES hzp
                       ,HZ_LOCATIONS hls
                   WHERE hzsu.site_use_id = p_system_header_tbl(sys_row).bill_to_site_use_id
                   AND   hzca.cust_acct_site_id = hzsu.cust_acct_site_id
                   AND   hzca.party_site_id = hps.party_site_id
                   AND   hps.party_id = hzp.party_id
                   AND   hps.location_id = hls.location_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).install_site_use_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).install_site_use_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_id
                         ,hzp.party_number
                         ,hzp.party_name
                         ,hzp.party_type
                         ,hls.address1
                         ,hls.address2
                         ,hls.address3
                         ,hls.address4
                         ,hls.city
                         ,hls.state
                         ,hls.postal_code
                         ,hls.country
                         ,hls.description
                         ,hls.location_id
                         ,hps.party_site_number
                   INTO p_system_header_tbl(sys_row).install_customer_id
                       ,p_system_header_tbl(sys_row).install_customer_number
                       ,p_system_header_tbl(sys_row).install_customer
                       ,p_system_header_tbl(sys_row).install_party_type
                       ,p_system_header_tbl(sys_row).install_address1
                       ,p_system_header_tbl(sys_row).install_address2
                       ,p_system_header_tbl(sys_row).install_address3
                       ,p_system_header_tbl(sys_row).install_address4
                       ,p_system_header_tbl(sys_row).install_location
                       ,p_system_header_tbl(sys_row).install_state
                       ,p_system_header_tbl(sys_row).install_postal_code
                       ,p_system_header_tbl(sys_row).install_country
                       ,p_system_header_tbl(sys_row).install_description
                       ,p_system_header_tbl(sys_row).install_location_id
                       ,p_system_header_tbl(sys_row).install_site_number
                   FROM HZ_PARTY_SITES hps
                       ,HZ_PARTIES hzp
                       ,HZ_LOCATIONS hls
                   WHERE hps.party_site_id = p_system_header_tbl(sys_row).install_site_use_id
                   AND   hps.party_id = hzp.party_id
                   AND   hps.location_id = hls.location_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).technical_contact_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).technical_contact_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_number
                         ,hzp.party_name
                   INTO p_system_header_tbl(sys_row).technical_contact_number
                       ,p_system_header_tbl(sys_row).technical_contact
                   FROM HZ_PARTIES hzp
                   WHERE hzp.party_id = p_system_header_tbl(sys_row).technical_contact_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).service_admin_contact_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).service_admin_contact_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_number
                         ,hzp.party_name
                   INTO p_system_header_tbl(sys_row).service_admin_contact_number
                       ,p_system_header_tbl(sys_row).service_admin_contact
                   FROM HZ_PARTIES hzp
                   WHERE hzp.party_id = p_system_header_tbl(sys_row).service_admin_contact_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).bill_to_contact_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).bill_to_contact_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_number
                         ,hzp.party_name
                   INTO p_system_header_tbl(sys_row).bill_to_contact_number
                       ,p_system_header_tbl(sys_row).bill_to_contact
                   FROM HZ_PARTIES hzp
                   WHERE hzp.party_id = p_system_header_tbl(sys_row).bill_to_contact_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).ship_to_contact_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).ship_to_contact_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT hzp.party_number
                         ,hzp.party_name
                   INTO p_system_header_tbl(sys_row).ship_to_contact_number
                       ,p_system_header_tbl(sys_row).ship_to_contact
                   FROM HZ_PARTIES hzp
                   WHERE hzp.party_id = p_system_header_tbl(sys_row).ship_to_contact_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).operating_unit_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).operating_unit_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT name
                   INTO p_system_header_tbl(sys_row).operating_unit_name
                   FROM HR_OPERATING_UNITS
                   WHERE organization_id = p_system_header_tbl(sys_row).operating_unit_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).parent_system_id IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).parent_system_id <> FND_API.G_MISS_NUM) ) THEN
                BEGIN
                   SELECT name
                         ,description
                   INTO p_system_header_tbl(sys_row).parent_name
                       ,p_system_header_tbl(sys_row).parent_description
                   FROM CSI_SYSTEMS_VL
                   WHERE system_id = p_system_header_tbl(sys_row).parent_system_id;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
             IF ( (p_system_header_tbl(sys_row).system_type_code IS NOT NULL) AND
                  (p_system_header_tbl(sys_row).system_type_code <> FND_API.G_MISS_CHAR) ) THEN
                BEGIN
                   SELECT meaning
                   INTO p_system_header_tbl(sys_row).system_type
                   FROM CSI_LOOKUPS
                   WHERE lookup_type = l_sys_type
                   AND   lookup_code = p_system_header_tbl(sys_row).system_type_code;
                EXCEPTION
                   WHEN OTHERS THEN
                      NULL;
                END;
             END IF;
             --
          END IF; -- sys_row EXISTS check
       END LOOP;
    END IF;
 END Resolve_ID_Columns;
 --
 PROCEDURE Get_System_History
   ( p_api_version                IN  NUMBER
    ,p_commit                     IN  VARCHAR2
    ,p_init_msg_list              IN  VARCHAR2
    ,p_validation_level           IN  NUMBER
    ,p_transaction_id             IN  NUMBER
    ,p_system_id                  IN  NUMBER
    ,x_system_history_tbl         OUT NOCOPY csi_datastructures_pub.systems_history_tbl
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
   ) IS
 --
   CURSOR txn_hist_csr(p_txn_id IN NUMBER
                      ,p_sys_id IN NUMBER) IS
   SELECT *
   FROM CSI_SYSTEMS_H
   WHERE transaction_id = p_txn_id
   AND   system_id = p_sys_id;
   --
   l_old_sys_header_rec      csi_datastructures_pub.system_header_rec;
   l_new_sys_header_rec      csi_datastructures_pub.system_header_rec;
   l_old_sys_header_tbl      csi_datastructures_pub.system_header_tbl;
   l_new_sys_header_tbl      csi_datastructures_pub.system_header_tbl;
   l_sys_history_rec         csi_datastructures_pub.system_history_rec;
   l_temp_sys_hist_rec       csi_datastructures_pub.system_history_rec;
   l_temp_sys_header_rec     csi_datastructures_pub.system_header_rec;
   l_api_name                CONSTANT   VARCHAR2(30) := 'get_system_history';
   l_api_version             CONSTANT   NUMBER       := 1.0;
   l_sys_count               NUMBER := 0;
 BEGIN
    IF fnd_api.to_boolean(p_commit) THEN
       SAVEPOINT    get_system_history;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                        p_api_version       ,
                                        l_api_name              ,
                                        G_PKG_NAME              )
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
       dbms_session.set_sql_trace(TRUE);
    END IF;

    -- End enable trace
    ****/

    -- Start API body
    --
    FOR l_hist_csr  IN txn_hist_csr(p_transaction_id,p_system_id)
    LOOP
       l_sys_history_rec := l_temp_sys_hist_rec;
       l_old_sys_header_rec := l_temp_sys_header_rec;
       l_new_sys_header_rec := l_temp_sys_header_rec;
       --
       IF NVL(l_hist_csr.old_customer_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_customer_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.customer_id := NULL;
          l_new_sys_header_rec.customer_id := NULL;
       ELSE
          l_old_sys_header_rec.customer_id := l_hist_csr.old_customer_id;
          l_new_sys_header_rec.customer_id := l_hist_csr.new_customer_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_system_type_code,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_system_type_code,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.system_type_code := NULL;
          l_new_sys_header_rec.system_type_code := NULL;
       ELSE
          l_old_sys_header_rec.system_type_code := l_hist_csr.old_system_type_code;
          l_new_sys_header_rec.system_type_code := l_hist_csr.new_system_type_code;
       END IF;
       --
       IF NVL(l_hist_csr.old_system_number,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_system_number,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.system_number := NULL;
          l_new_sys_header_rec.system_number := NULL;
       ELSE
          l_old_sys_header_rec.system_number := l_hist_csr.old_system_number;
          l_new_sys_header_rec.system_number := l_hist_csr.new_system_number;
       END IF;
       --
       IF NVL(l_hist_csr.old_parent_system_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_parent_system_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.parent_system_id := NULL;
          l_new_sys_header_rec.parent_system_id := NULL;
       ELSE
          l_old_sys_header_rec.parent_system_id := l_hist_csr.old_parent_system_id;
          l_new_sys_header_rec.parent_system_id := l_hist_csr.new_parent_system_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_ship_to_contact_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_ship_to_contact_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.ship_to_contact_id := NULL;
          l_new_sys_header_rec.ship_to_contact_id := NULL;
       ELSE
          l_old_sys_header_rec.ship_to_contact_id := l_hist_csr.old_ship_to_contact_id;
          l_new_sys_header_rec.ship_to_contact_id := l_hist_csr.new_ship_to_contact_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_bill_to_contact_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_bill_to_contact_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.bill_to_contact_id := NULL;
          l_new_sys_header_rec.bill_to_contact_id := NULL;
       ELSE
          l_old_sys_header_rec.bill_to_contact_id := l_hist_csr.old_bill_to_contact_id;
          l_new_sys_header_rec.bill_to_contact_id := l_hist_csr.new_bill_to_contact_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_technical_contact_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_technical_contact_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.technical_contact_id := NULL;
          l_new_sys_header_rec.technical_contact_id := NULL;
       ELSE
          l_old_sys_header_rec.technical_contact_id := l_hist_csr.old_technical_contact_id;
          l_new_sys_header_rec.technical_contact_id := l_hist_csr.new_technical_contact_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_service_admin_contact_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_service_admin_contact_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.service_admin_contact_id := NULL;
          l_new_sys_header_rec.service_admin_contact_id := NULL;
       ELSE
          l_old_sys_header_rec.service_admin_contact_id := l_hist_csr.old_service_admin_contact_id;
          l_new_sys_header_rec.service_admin_contact_id := l_hist_csr.new_service_admin_contact_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_ship_to_site_use_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_ship_to_site_use_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.ship_to_site_use_id := NULL;
          l_new_sys_header_rec.ship_to_site_use_id := NULL;
       ELSE
          l_old_sys_header_rec.ship_to_site_use_id := l_hist_csr.old_ship_to_site_use_id;
          l_new_sys_header_rec.ship_to_site_use_id := l_hist_csr.new_ship_to_site_use_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_bill_to_site_use_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_bill_to_site_use_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.bill_to_site_use_id := NULL;
          l_new_sys_header_rec.bill_to_site_use_id := NULL;
       ELSE
          l_old_sys_header_rec.bill_to_site_use_id := l_hist_csr.old_bill_to_site_use_id;
          l_new_sys_header_rec.bill_to_site_use_id := l_hist_csr.new_bill_to_site_use_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_install_site_use_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_install_site_use_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.install_site_use_id := NULL;
          l_new_sys_header_rec.install_site_use_id := NULL;
       ELSE
          l_old_sys_header_rec.install_site_use_id := l_hist_csr.old_install_site_use_id;
          l_new_sys_header_rec.install_site_use_id := l_hist_csr.new_install_site_use_id;
       END IF;
       --
       IF NVL(l_hist_csr.old_coterminate_day_month,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_coterminate_day_month,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.coterminate_day_month := NULL;
          l_new_sys_header_rec.coterminate_day_month := NULL;
       ELSE
          l_old_sys_header_rec.coterminate_day_month := l_hist_csr.old_coterminate_day_month;
          l_new_sys_header_rec.coterminate_day_month := l_hist_csr.new_coterminate_day_month;
       END IF;
       --
       IF NVL(l_hist_csr.old_start_date_active,fnd_api.g_miss_date) =
                                         NVL(l_hist_csr.new_start_date_active,fnd_api.g_miss_date) THEN
          l_old_sys_header_rec.start_date_active := NULL;
          l_new_sys_header_rec.start_date_active := NULL;
       ELSE
          l_old_sys_header_rec.start_date_active := l_hist_csr.old_start_date_active;
          l_new_sys_header_rec.start_date_active := l_hist_csr.new_start_date_active;
       END IF;
       --
       IF NVL(l_hist_csr.old_end_date_active,fnd_api.g_miss_date) =
                                         NVL(l_hist_csr.new_end_date_active,fnd_api.g_miss_date) THEN
          l_old_sys_header_rec.end_date_active := NULL;
          l_new_sys_header_rec.end_date_active := NULL;
       ELSE
          l_old_sys_header_rec.end_date_active := l_hist_csr.old_end_date_active;
          l_new_sys_header_rec.end_date_active := l_hist_csr.new_end_date_active;
       END IF;
       --
       IF NVL(l_hist_csr.old_autocreated_from_system,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_autocreated_from_system,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.autocreated_from_system_id := NULL;
          l_new_sys_header_rec.autocreated_from_system_id := NULL;
       ELSE
          l_old_sys_header_rec.autocreated_from_system_id := l_hist_csr.old_autocreated_from_system;
          l_new_sys_header_rec.autocreated_from_system_id := l_hist_csr.new_autocreated_from_system;
       END IF;
       --
       IF NVL(l_hist_csr.old_config_system_type,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_config_system_type,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.config_system_type := NULL;
          l_new_sys_header_rec.config_system_type := NULL;
       ELSE
          l_old_sys_header_rec.config_system_type := l_hist_csr.old_config_system_type;
          l_new_sys_header_rec.config_system_type := l_hist_csr.new_config_system_type;
       END IF;
       --
       IF NVL(l_hist_csr.old_name,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_name,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.name := NULL;
          l_new_sys_header_rec.name := NULL;
       ELSE
          l_old_sys_header_rec.name := l_hist_csr.old_name;
          l_new_sys_header_rec.name := l_hist_csr.new_name;
       END IF;
       --
       IF NVL(l_hist_csr.old_description,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_description,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.description := NULL;
          l_new_sys_header_rec.description := NULL;
       ELSE
          l_old_sys_header_rec.description := l_hist_csr.old_description;
          l_new_sys_header_rec.description := l_hist_csr.new_description;
       END IF;
       --
       IF NVL(l_hist_csr.old_context,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_context,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.context := NULL;
          l_new_sys_header_rec.context := NULL;
       ELSE
          l_old_sys_header_rec.context := l_hist_csr.old_context;
          l_new_sys_header_rec.context := l_hist_csr.new_context;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute1,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute1,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute1 := NULL;
          l_new_sys_header_rec.attribute1 := NULL;
       ELSE
          l_old_sys_header_rec.attribute1 := l_hist_csr.old_attribute1;
          l_new_sys_header_rec.attribute1 := l_hist_csr.new_attribute1;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute2,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute2,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute2 := NULL;
          l_new_sys_header_rec.attribute2 := NULL;
       ELSE
          l_old_sys_header_rec.attribute2 := l_hist_csr.old_attribute2;
          l_new_sys_header_rec.attribute2 := l_hist_csr.new_attribute2;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute3,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute3,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute3 := NULL;
          l_new_sys_header_rec.attribute3 := NULL;
       ELSE
          l_old_sys_header_rec.attribute3 := l_hist_csr.old_attribute3;
          l_new_sys_header_rec.attribute3 := l_hist_csr.new_attribute3;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute4,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute4,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute4 := NULL;
          l_new_sys_header_rec.attribute4 := NULL;
       ELSE
          l_old_sys_header_rec.attribute4 := l_hist_csr.old_attribute4;
          l_new_sys_header_rec.attribute4 := l_hist_csr.new_attribute4;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute5,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute5,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute5 := NULL;
          l_new_sys_header_rec.attribute5 := NULL;
       ELSE
          l_old_sys_header_rec.attribute5 := l_hist_csr.old_attribute5;
          l_new_sys_header_rec.attribute5 := l_hist_csr.new_attribute5;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute6,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute6,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute6 := NULL;
          l_new_sys_header_rec.attribute6 := NULL;
       ELSE
          l_old_sys_header_rec.attribute6 := l_hist_csr.old_attribute6;
          l_new_sys_header_rec.attribute6 := l_hist_csr.new_attribute6;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute7,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute7,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute7 := NULL;
          l_new_sys_header_rec.attribute7 := NULL;
       ELSE
          l_old_sys_header_rec.attribute7 := l_hist_csr.old_attribute7;
          l_new_sys_header_rec.attribute7 := l_hist_csr.new_attribute7;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute8,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute8,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute8 := NULL;
          l_new_sys_header_rec.attribute8 := NULL;
       ELSE
          l_old_sys_header_rec.attribute8 := l_hist_csr.old_attribute8;
          l_new_sys_header_rec.attribute8 := l_hist_csr.new_attribute8;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute9,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute9,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute9 := NULL;
          l_new_sys_header_rec.attribute9 := NULL;
       ELSE
          l_old_sys_header_rec.attribute9 := l_hist_csr.old_attribute9;
          l_new_sys_header_rec.attribute9 := l_hist_csr.new_attribute9;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute10,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute10,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute10 := NULL;
          l_new_sys_header_rec.attribute10 := NULL;
       ELSE
          l_old_sys_header_rec.attribute10 := l_hist_csr.old_attribute10;
          l_new_sys_header_rec.attribute10 := l_hist_csr.new_attribute10;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute11,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute11,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute11 := NULL;
          l_new_sys_header_rec.attribute11 := NULL;
       ELSE
          l_old_sys_header_rec.attribute11 := l_hist_csr.old_attribute11;
          l_new_sys_header_rec.attribute11 := l_hist_csr.new_attribute11;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute12,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute12,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute12 := NULL;
          l_new_sys_header_rec.attribute12 := NULL;
       ELSE
          l_old_sys_header_rec.attribute12 := l_hist_csr.old_attribute12;
          l_new_sys_header_rec.attribute12 := l_hist_csr.new_attribute12;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute13,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute13,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute13 := NULL;
          l_new_sys_header_rec.attribute13 := NULL;
       ELSE
          l_old_sys_header_rec.attribute13 := l_hist_csr.old_attribute13;
          l_new_sys_header_rec.attribute13 := l_hist_csr.new_attribute13;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute14,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute14,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute14 := NULL;
          l_new_sys_header_rec.attribute14 := NULL;
       ELSE
          l_old_sys_header_rec.attribute14 := l_hist_csr.old_attribute14;
          l_new_sys_header_rec.attribute14 := l_hist_csr.new_attribute14;
       END IF;
       --
       IF NVL(l_hist_csr.old_attribute15,fnd_api.g_miss_char) =
                                         NVL(l_hist_csr.new_attribute15,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.attribute15 := NULL;
          l_new_sys_header_rec.attribute15 := NULL;
       ELSE
          l_old_sys_header_rec.attribute15 := l_hist_csr.old_attribute15;
          l_new_sys_header_rec.attribute15 := l_hist_csr.new_attribute15;
       END IF;
       --
       IF NVL(l_hist_csr.old_operating_unit_id,fnd_api.g_miss_num) =
                                         NVL(l_hist_csr.new_operating_unit_id,fnd_api.g_miss_num) THEN
          l_old_sys_header_rec.operating_unit_id := NULL;
          l_new_sys_header_rec.operating_unit_id := NULL;
       ELSE
          l_old_sys_header_rec.operating_unit_id := l_hist_csr.old_operating_unit_id;
          l_new_sys_header_rec.operating_unit_id := l_hist_csr.new_operating_unit_id;
       END IF;
       --
       -- Resolve the IDs
       l_old_sys_header_tbl(1) := l_old_sys_header_rec;
       csi_systems_pvt.Resolve_ID_Columns(p_system_header_tbl => l_old_sys_header_tbl);
       l_old_sys_header_rec := l_old_sys_header_tbl(1);
       --
       l_new_sys_header_tbl(1) := l_new_sys_header_rec;
       csi_systems_pvt.Resolve_ID_Columns(p_system_header_tbl => l_new_sys_header_tbl);
       l_new_sys_header_rec := l_new_sys_header_tbl(1);
       --
       -- Check for the Resolved Column values and assign NULL appropriately
       IF NVL(l_old_sys_header_rec.name,fnd_api.g_miss_char) =
                                   NVL(l_new_sys_header_rec.name,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.name := NULL;
          l_new_sys_header_rec.name := NULL;
       END IF;
       --
       IF NVL(l_old_sys_header_rec.description,fnd_api.g_miss_char) =
                                   NVL(l_new_sys_header_rec.description,fnd_api.g_miss_char) THEN
          l_old_sys_header_rec.description := NULL;
          l_new_sys_header_rec.description := NULL;
       END IF;
       --
       -- Build the l_system_history_rec
       l_sys_history_rec.system_history_id := l_hist_csr.system_history_id;
       l_sys_history_rec.system_id := l_hist_csr.system_id;
       l_sys_history_rec.transaction_id := l_hist_csr.transaction_id;
       l_sys_history_rec.old_customer_id := l_old_sys_header_rec.customer_id;
       l_sys_history_rec.new_customer_id := l_new_sys_header_rec.customer_id;
       l_sys_history_rec.old_system_type_code := l_old_sys_header_rec.system_type_code;
       l_sys_history_rec.new_system_type_code := l_new_sys_header_rec.system_type_code;
       l_sys_history_rec.old_system_number := l_old_sys_header_rec.system_number;
       l_sys_history_rec.new_system_number := l_new_sys_header_rec.system_number;
       l_sys_history_rec.old_parent_system_id := l_old_sys_header_rec.parent_system_id;
       l_sys_history_rec.new_parent_system_id := l_new_sys_header_rec.parent_system_id;
       l_sys_history_rec.old_ship_to_contact_id := l_old_sys_header_rec.ship_to_contact_id;
       l_sys_history_rec.new_ship_to_contact_id := l_new_sys_header_rec.ship_to_contact_id;
       l_sys_history_rec.old_bill_to_contact_id := l_old_sys_header_rec.bill_to_contact_id;
       l_sys_history_rec.new_bill_to_contact_id := l_new_sys_header_rec.bill_to_contact_id;
       l_sys_history_rec.old_technical_contact_id := l_old_sys_header_rec.technical_contact_id;
       l_sys_history_rec.new_technical_contact_id := l_new_sys_header_rec.technical_contact_id;
       l_sys_history_rec.old_service_admin_contact_id := l_old_sys_header_rec.service_admin_contact_id;
       l_sys_history_rec.new_service_admin_contact_id := l_new_sys_header_rec.service_admin_contact_id;
       l_sys_history_rec.old_ship_to_site_use_id := l_old_sys_header_rec.ship_to_site_use_id;
       l_sys_history_rec.new_ship_to_site_use_id := l_new_sys_header_rec.ship_to_site_use_id;
       l_sys_history_rec.old_bill_to_site_use_id := l_old_sys_header_rec.bill_to_site_use_id;
       l_sys_history_rec.new_bill_to_site_use_id := l_new_sys_header_rec.bill_to_site_use_id;
       l_sys_history_rec.old_install_site_use_id := l_old_sys_header_rec.install_site_use_id;
       l_sys_history_rec.new_install_site_use_id := l_new_sys_header_rec.install_site_use_id;
       l_sys_history_rec.old_coterminate_day_month := l_old_sys_header_rec.coterminate_day_month;
       l_sys_history_rec.new_coterminate_day_month := l_new_sys_header_rec.coterminate_day_month;
       l_sys_history_rec.old_start_date_active := l_old_sys_header_rec.start_date_active;
       l_sys_history_rec.new_start_date_active := l_new_sys_header_rec.start_date_active;
       l_sys_history_rec.old_end_date_active := l_old_sys_header_rec.end_date_active;
       l_sys_history_rec.new_end_date_active := l_new_sys_header_rec.end_date_active;
       l_sys_history_rec.old_autocreated_from_system := l_old_sys_header_rec.autocreated_from_system_id;
       l_sys_history_rec.new_autocreated_from_system := l_new_sys_header_rec.autocreated_from_system_id;
       l_sys_history_rec.old_config_system_type := l_old_sys_header_rec.config_system_type;
       l_sys_history_rec.new_config_system_type := l_new_sys_header_rec.config_system_type;
       l_sys_history_rec.old_context := l_old_sys_header_rec.context;
       l_sys_history_rec.new_context := l_new_sys_header_rec.context;
       l_sys_history_rec.old_attribute1 := l_old_sys_header_rec.attribute1;
       l_sys_history_rec.new_attribute1 := l_new_sys_header_rec.attribute1;
       l_sys_history_rec.old_attribute2 := l_old_sys_header_rec.attribute2;
       l_sys_history_rec.new_attribute2 := l_new_sys_header_rec.attribute2;
       l_sys_history_rec.old_attribute3 := l_old_sys_header_rec.attribute3;
       l_sys_history_rec.new_attribute3 := l_new_sys_header_rec.attribute3;
       l_sys_history_rec.old_attribute4 := l_old_sys_header_rec.attribute4;
       l_sys_history_rec.new_attribute4 := l_new_sys_header_rec.attribute4;
       l_sys_history_rec.old_attribute5 := l_old_sys_header_rec.attribute5;
       l_sys_history_rec.new_attribute5 := l_new_sys_header_rec.attribute5;
       l_sys_history_rec.old_attribute6 := l_old_sys_header_rec.attribute6;
       l_sys_history_rec.new_attribute6 := l_new_sys_header_rec.attribute6;
       l_sys_history_rec.old_attribute7 := l_old_sys_header_rec.attribute7;
       l_sys_history_rec.new_attribute7 := l_new_sys_header_rec.attribute7;
       l_sys_history_rec.old_attribute8 := l_old_sys_header_rec.attribute8;
       l_sys_history_rec.new_attribute8 := l_new_sys_header_rec.attribute8;
       l_sys_history_rec.old_attribute9 := l_old_sys_header_rec.attribute9;
       l_sys_history_rec.new_attribute9 := l_new_sys_header_rec.attribute9;
       l_sys_history_rec.old_attribute10 := l_old_sys_header_rec.attribute10;
       l_sys_history_rec.new_attribute10 := l_new_sys_header_rec.attribute10;
       l_sys_history_rec.old_attribute11 := l_old_sys_header_rec.attribute11;
       l_sys_history_rec.new_attribute11 := l_new_sys_header_rec.attribute11;
       l_sys_history_rec.old_attribute12 := l_old_sys_header_rec.attribute12;
       l_sys_history_rec.new_attribute12 := l_new_sys_header_rec.attribute12;
       l_sys_history_rec.old_attribute13 := l_old_sys_header_rec.attribute13;
       l_sys_history_rec.new_attribute13 := l_new_sys_header_rec.attribute13;
       l_sys_history_rec.old_attribute14 := l_old_sys_header_rec.attribute14;
       l_sys_history_rec.new_attribute14 := l_new_sys_header_rec.attribute14;
       l_sys_history_rec.old_attribute15 := l_old_sys_header_rec.attribute15;
       l_sys_history_rec.new_attribute15 := l_new_sys_header_rec.attribute15;
       l_sys_history_rec.old_name := l_old_sys_header_rec.name;
       l_sys_history_rec.new_name := l_new_sys_header_rec.name;
       l_sys_history_rec.old_description := l_old_sys_header_rec.description;
       l_sys_history_rec.new_description := l_new_sys_header_rec.description;
       l_sys_history_rec.old_operating_unit_id := l_old_sys_header_rec.operating_unit_id;
       l_sys_history_rec.new_operating_unit_id := l_new_sys_header_rec.operating_unit_id;
       l_sys_history_rec.old_operating_unit_name := l_old_sys_header_rec.operating_unit_name;
       l_sys_history_rec.new_operating_unit_name := l_new_sys_header_rec.operating_unit_name;
       l_sys_history_rec.old_system_type := l_old_sys_header_rec.system_type;
       l_sys_history_rec.new_system_type := l_new_sys_header_rec.system_type;
       l_sys_history_rec.old_parent_name := l_old_sys_header_rec.parent_name;
       l_sys_history_rec.new_parent_name := l_new_sys_header_rec.parent_name;
       l_sys_history_rec.old_ship_to_address1 := l_old_sys_header_rec.ship_to_address1;
       l_sys_history_rec.new_ship_to_address1 := l_new_sys_header_rec.ship_to_address1;
       l_sys_history_rec.old_ship_to_address2 := l_old_sys_header_rec.ship_to_address2;
       l_sys_history_rec.new_ship_to_address2 := l_new_sys_header_rec.ship_to_address2;
       l_sys_history_rec.old_ship_to_address3 := l_old_sys_header_rec.ship_to_address3;
       l_sys_history_rec.new_ship_to_address3 := l_new_sys_header_rec.ship_to_address3;
       l_sys_history_rec.old_ship_to_address4 := l_old_sys_header_rec.ship_to_address4;
       l_sys_history_rec.new_ship_to_address4 := l_new_sys_header_rec.ship_to_address4;
       l_sys_history_rec.old_ship_to_location := l_old_sys_header_rec.ship_to_location;
       l_sys_history_rec.new_ship_to_location := l_new_sys_header_rec.ship_to_location;
       l_sys_history_rec.old_ship_state := l_old_sys_header_rec.ship_state;
       l_sys_history_rec.new_ship_state := l_new_sys_header_rec.ship_state;
       l_sys_history_rec.old_ship_postal_code := l_old_sys_header_rec.ship_postal_code;
       l_sys_history_rec.new_ship_postal_code := l_new_sys_header_rec.ship_postal_code;
       l_sys_history_rec.old_ship_country := l_old_sys_header_rec.ship_country;
       l_sys_history_rec.new_ship_country := l_new_sys_header_rec.ship_country;
       l_sys_history_rec.old_ship_to_customer := l_old_sys_header_rec.ship_to_customer;
       l_sys_history_rec.new_ship_to_customer := l_new_sys_header_rec.ship_to_customer;
       l_sys_history_rec.old_ship_to_customer_number := l_old_sys_header_rec.ship_to_customer_number;
       l_sys_history_rec.new_ship_to_customer_number := l_new_sys_header_rec.ship_to_customer_number;
       l_sys_history_rec.old_bill_to_address1 := l_old_sys_header_rec.bill_to_address1;
       l_sys_history_rec.new_bill_to_address1 := l_new_sys_header_rec.bill_to_address1;
       l_sys_history_rec.old_bill_to_address2 := l_old_sys_header_rec.bill_to_address2;
       l_sys_history_rec.new_bill_to_address2 := l_new_sys_header_rec.bill_to_address2;
       l_sys_history_rec.old_bill_to_address3 := l_old_sys_header_rec.bill_to_address3;
       l_sys_history_rec.new_bill_to_address3 := l_new_sys_header_rec.bill_to_address3;
       l_sys_history_rec.old_bill_to_address4 := l_old_sys_header_rec.bill_to_address4;
       l_sys_history_rec.new_bill_to_address4 := l_new_sys_header_rec.bill_to_address4;
       l_sys_history_rec.old_bill_to_location := l_old_sys_header_rec.bill_to_location;
       l_sys_history_rec.new_bill_to_location := l_new_sys_header_rec.bill_to_location;
       l_sys_history_rec.old_bill_state := l_old_sys_header_rec.bill_state;
       l_sys_history_rec.new_bill_state := l_new_sys_header_rec.bill_state;
       l_sys_history_rec.old_bill_postal_code := l_old_sys_header_rec.bill_postal_code;
       l_sys_history_rec.new_bill_postal_code := l_new_sys_header_rec.bill_postal_code;
       l_sys_history_rec.old_bill_country := l_old_sys_header_rec.bill_country;
       l_sys_history_rec.new_bill_country := l_new_sys_header_rec.bill_country;
       l_sys_history_rec.old_bill_to_customer := l_old_sys_header_rec.bill_to_customer;
       l_sys_history_rec.new_bill_to_customer := l_new_sys_header_rec.bill_to_customer;
       l_sys_history_rec.old_bill_to_customer_number := l_old_sys_header_rec.bill_to_customer_number;
       l_sys_history_rec.new_bill_to_customer_number := l_new_sys_header_rec.bill_to_customer_number;
       l_sys_history_rec.old_install_address1 := l_old_sys_header_rec.install_address1;
       l_sys_history_rec.new_install_address1 := l_new_sys_header_rec.install_address1;
       l_sys_history_rec.old_install_address2 := l_old_sys_header_rec.install_address2;
       l_sys_history_rec.new_install_address2 := l_new_sys_header_rec.install_address2;
       l_sys_history_rec.old_install_address3 := l_old_sys_header_rec.install_address3;
       l_sys_history_rec.new_install_address3 := l_new_sys_header_rec.install_address3;
       l_sys_history_rec.old_install_address4 := l_old_sys_header_rec.install_address4;
       l_sys_history_rec.new_install_address4 := l_new_sys_header_rec.install_address4;
       l_sys_history_rec.old_install_location := l_old_sys_header_rec.install_location;
       l_sys_history_rec.new_install_location := l_new_sys_header_rec.install_location;
       l_sys_history_rec.old_install_state := l_old_sys_header_rec.install_state;
       l_sys_history_rec.new_install_state := l_new_sys_header_rec.install_state;
       l_sys_history_rec.old_install_postal_code := l_old_sys_header_rec.install_postal_code;
       l_sys_history_rec.new_install_postal_code := l_new_sys_header_rec.install_postal_code;
       l_sys_history_rec.old_install_country := l_old_sys_header_rec.install_country;
       l_sys_history_rec.new_install_country := l_new_sys_header_rec.install_country;
       l_sys_history_rec.old_install_customer := l_old_sys_header_rec.install_customer;
       l_sys_history_rec.new_install_customer := l_new_sys_header_rec.install_customer;
       l_sys_history_rec.old_install_customer_number := l_old_sys_header_rec.install_customer_number;
       l_sys_history_rec.new_install_customer_number := l_new_sys_header_rec.install_customer_number;
       l_sys_history_rec.old_ship_to_contact_number := l_old_sys_header_rec.ship_to_contact_number;
       l_sys_history_rec.new_ship_to_contact_number := l_new_sys_header_rec.ship_to_contact_number;
       l_sys_history_rec.old_bill_to_contact_number := l_old_sys_header_rec.bill_to_contact_number;
       l_sys_history_rec.new_bill_to_contact_number := l_new_sys_header_rec.bill_to_contact_number;
       l_sys_history_rec.old_technical_contact_number := l_old_sys_header_rec.technical_contact_number;
       l_sys_history_rec.new_technical_contact_number := l_new_sys_header_rec.technical_contact_number;
       l_sys_history_rec.old_serv_admin_contact_number := l_old_sys_header_rec.service_admin_contact_number;
       l_sys_history_rec.new_serv_admin_contact_number := l_new_sys_header_rec.service_admin_contact_number;
       l_sys_history_rec.old_ship_to_contact := l_old_sys_header_rec.ship_to_contact;
       l_sys_history_rec.new_ship_to_contact := l_new_sys_header_rec.ship_to_contact;
       l_sys_history_rec.old_bill_to_contact := l_old_sys_header_rec.bill_to_contact;
       l_sys_history_rec.new_bill_to_contact := l_new_sys_header_rec.bill_to_contact;
       l_sys_history_rec.old_technical_contact := l_old_sys_header_rec.technical_contact;
       l_sys_history_rec.new_technical_contact := l_new_sys_header_rec.technical_contact;
       l_sys_history_rec.old_serv_admin_contact := l_old_sys_header_rec.service_admin_contact;
       l_sys_history_rec.new_serv_admin_contact := l_new_sys_header_rec.service_admin_contact;
       l_sys_history_rec.object_version_number := l_hist_csr.object_version_number;
       --
       l_sys_count := l_sys_count + 1;
       x_system_history_tbl(l_sys_count) := l_sys_history_rec;
    END LOOP;
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
       dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
               (p_count        =>      x_msg_count ,
                p_data     =>      x_msg_data      );
 EXCEPTION
    WHEN OTHERS THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF fnd_api.to_boolean(p_commit) THEN
            ROLLBACK TO get_system_history;
         END IF;
         IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
                  ( G_PKG_NAME, l_api_name );
         END IF;
         FND_MSG_PUB.Count_And_Get
               ( p_count         =>      x_msg_count,
                 p_data      =>      x_msg_data);

 END Get_System_History;
 --
END csi_systems_pvt;

/
