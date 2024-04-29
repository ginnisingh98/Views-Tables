--------------------------------------------------------
--  DDL for Package Body JTF_TASK_DEPENDENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_DEPENDENCY_PVT" AS
/* $Header: jtfvtkeb.pls 120.3 2006/02/22 03:37:52 sbarat ship $ */
    g_pkg_name    VARCHAR2(30) := 'JTF_TASK_DEPENDENCY_PVT';


    function validate_dependency(p_task_id in number,
                                 p_dependent_on_task_id in number,
                                 p_dependency_type_code in varchar2,
                                 p_adjustment_time in number,
                                 p_adjustment_time_uom in varchar2,
                                 p_validated_flag in varchar2 default 'N'
    )
    return varchar2
    is

      -- Cursor for getting scheduled_start_date and scheduled_end_date
      cursor c_task_dates(l_task_id in number)
      is
        select scheduled_start_date ssd, scheduled_end_date sed
        from   jtf_tasks_b
        where  task_id = l_task_id;

      l_child_start_date   date;
      l_master_start_date  date;
      l_child_end_date     date;
      l_master_end_date    date;

    begin

      -- If validated_flag is null or not 'Y', simply do nothing.
      if (p_validated_flag is null or p_validated_flag <> 'Y')
      then
        return fnd_api.g_ret_sts_success;
      end if;

      -- Get the scheduled dates for task
      open c_task_dates(p_task_id);
      fetch c_task_dates into l_child_start_date, l_child_end_date;
      close c_task_dates;

      -- Get the scheduled dates for the dependent task of the task
      open c_task_dates(p_dependent_on_task_id);
      fetch c_task_dates into l_master_start_date, l_master_end_date;
      close c_task_dates;

      -- If scheduled_start_date and scheduled_end_date for
      -- parent task and child task are null, do nothing.
      if (l_child_start_date is null and
          l_master_start_date is null and
          l_child_end_date is null and
          l_master_end_date is null)
      then
        return fnd_api.g_ret_sts_success;
      end if;

      -- Dependency type code is 'SS'
      if (p_dependency_type_code = 'SS' and
          l_child_start_date is not null and
          l_master_start_date is not null)
      then
        l_master_start_date :=
          JTF_TASK_UTL_EXT.adjust_date(l_master_start_date,
                                       p_adjustment_time,
                                       p_adjustment_time_uom);

        if l_master_start_date > l_child_start_date
        then
          fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPEND_S2S');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        end if;

      -- Dependency type code is 'FF'
      elsif (p_dependency_type_code = 'FF' and
              l_child_end_date is not null and
              l_master_end_date is not null)
      then
        l_master_end_date :=
          JTF_TASK_UTL_EXT.adjust_date(l_master_end_date,
                                       p_adjustment_time,
                                       p_adjustment_time_uom);

        if (l_master_end_date > l_child_end_date)
        then
          fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPEND_F2F');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        end if;

      -- Dependency type code is 'FS'
      elsif (p_dependency_type_code = 'FS' and
              l_child_end_date is not null and
              l_master_start_date is not null)
      then
        l_master_end_date :=
          JTF_TASK_UTL_EXT.adjust_date(l_master_end_date,
                                       p_adjustment_time,
                                       p_adjustment_time_uom);

        if (l_master_end_date > l_child_start_date)
        then
          fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPEND_F2S');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        end if;

      -- Dependency type code is 'SF'
      elsif (p_dependency_type_code = 'SF' and
              l_child_start_date is not null and
              l_master_end_date is not null)
      then
        l_master_start_date :=
          JTF_TASK_UTL_EXT.adjust_date(l_master_start_date,
                                       p_adjustment_time,
                                       p_adjustment_time_uom);

        if (l_master_start_date > l_child_end_date)
        then
          fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPEND_S2F');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        end if;
      end if;

      return fnd_api.g_ret_sts_success;

      exception
        when fnd_api.g_exc_error
        then
          return fnd_api.g_ret_sts_error;
        when others
        then
          fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
          fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
          fnd_msg_pub.add;
          return fnd_api.g_ret_sts_unexp_error;
    end;


    function validate_task_dependency (p_task_id              in number,
                                       p_dependent_on_task_id in number,
                                       p_dependency_id        in number,
                                       p_template_flag        in varchar2)
    return varchar2
    is
      x                              char;
      l_source_object_type_code      jtf_tasks_b.source_object_type_code%TYPE;
      l_source_object_id             jtf_tasks_b.source_object_id%TYPE;

      -- Cursor for checking if there is a duplicate dependency
      cursor c_check_dup_temp_y (l_task_id in number,
                  l_dependent_on_task_id in number,
                  l_dependency_id in number)
      is
        select 1
        from   jtf_task_depends
        where  task_id = l_task_id
          and dependent_on_task_id = l_dependent_on_task_id
          and dependency_id <> l_dependency_id
          and template_flag = 'Y';

      -- Cursor for checking if there is a duplicate dependency
      cursor c_check_dup_temp_n (l_task_id in number,
                  l_dependent_on_task_id in number,
                  l_dependency_id in number)
      is
        select 1
        from   jtf_task_depends
        where  task_id = l_task_id
	  and  dependent_on_task_id = l_dependent_on_task_id
	  and  dependency_id <> l_dependency_id
	  and (template_flag = 'N' or template_flag is null);

      -- Cursor for checking if there is a cyclic chain dependency
      cursor c_check_cyc_temp_y (l_dependency_id in number)
      is
        select 1
        from   jtf_task_depends
        where  task_id = p_dependent_on_task_id
          and  dependency_id <> l_dependency_id
          connect by prior task_id = dependent_on_task_id
          start with dependent_on_task_id = p_task_id
          and  template_flag = 'Y';

      -- Cursor for checking if there is a cyclic chain dependency
      cursor c_check_cyc_temp_n (l_dependency_id in number)
      is
        select 1
        from   jtf_task_depends
        where  task_id = p_dependent_on_task_id
          and  dependency_id <> l_dependency_id
          connect by prior task_id = dependent_on_task_id
          start with dependent_on_task_id = p_task_id
          and  (template_flag = 'N' or template_flag is null);

        l_return_status varchar2(1):= fnd_api.g_ret_sts_success;

    begin

      if p_task_id = p_dependent_on_task_id
      then
        l_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name ('JTF', 'JTF_TASK_ITSELF_DEPENDS');
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
      end if;

      if (p_template_flag = 'Y')
      then
        open c_check_dup_temp_y(p_task_id, p_dependent_on_task_id, p_dependency_id);
        fetch c_check_dup_temp_y into x;

          if c_check_dup_temp_y%found
          then
            close c_check_dup_temp_y;
            l_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_EXISTS');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          end if;
        close c_check_dup_temp_y;

        open c_check_dup_temp_y(p_dependent_on_task_id, p_task_id, p_dependency_id);
        fetch c_check_dup_temp_y into x;

          if c_check_dup_temp_y%found
          then
            close c_check_dup_temp_y;
            l_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_RVERSE_EXISTS');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          end if;
        close c_check_dup_temp_y;

        open c_check_cyc_temp_y(p_dependency_id);
        fetch c_check_cyc_temp_y into x;

          if c_check_cyc_temp_y%found
          then
            close c_check_cyc_temp_y;
            l_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_CYCLICAL');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          end if;
        close c_check_cyc_temp_y;
      elsif (p_template_flag is null or p_template_flag = 'N')
      then
        open c_check_dup_temp_n(p_task_id, p_dependent_on_task_id, p_dependency_id);
        fetch c_check_dup_temp_n into x;

          if c_check_dup_temp_n%found
          then
            close c_check_dup_temp_n;
            l_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_EXISTS');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          end if;
        close c_check_dup_temp_n;

        open c_check_dup_temp_n(p_dependent_on_task_id, p_task_id, p_dependency_id);
        fetch c_check_dup_temp_n into x;

          if c_check_dup_temp_n%found
          then
            close c_check_dup_temp_n;
            l_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_RVERSE_EXISTS');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          end if;
        close c_check_dup_temp_n;

        open c_check_cyc_temp_n(p_dependency_id);
        fetch c_check_cyc_temp_n into x;

          if c_check_cyc_temp_n%found
          then
            close c_check_cyc_temp_n;
            l_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_CYCLICAL');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          end if;
        close c_check_cyc_temp_n;
      end if;

      return l_return_status;

      exception
        when fnd_api.g_exc_error
        then
          return fnd_api.g_ret_sts_error;
        when fnd_api.g_exc_unexpected_error
        then
          return fnd_api.g_ret_sts_unexp_error;
        when others
        then
          fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
          fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
          fnd_msg_pub.add;
          return fnd_api.g_ret_sts_unexp_error;
    end;

    procedure reconnect_dependency (p_api_version   in number,
                                    p_init_msg_list in varchar2 default fnd_api.g_false,
                                    p_commit        in varchar2 default fnd_api.g_false,
                                    x_return_status out nocopy varchar2,
                                    x_msg_data      out nocopy varchar2,
                                    x_msg_count     out nocopy number,
                                    p_task_id       in number,
                                    p_template_flag in varchar2 default 'N')
    is
      l_api_version    constant number                      := 1.0;
      l_api_name       constant varchar2(30)                := 'RECONNECT_DEPENDENCY';
      l_dependency_id  jtf_task_depends.dependency_id%TYPE  := -1;
      x_dependency_id  jtf_task_depends.dependency_id%TYPE;

      -- Cursor for finding successor dependencies
      cursor c_successor_dependency
        is
          select dependency_id,
            task_id,
            dependency_type_code,
            adjustment_time,
            adjustment_time_uom,
            object_version_number
          from   jtf_task_depends
          where  dependent_on_task_id = p_task_id and
            (template_flag is null or template_flag = 'N');

      -- Cursor for finding successor dependencies for template
      cursor c_suc_template_dependency
        is
          select dependency_id,
            task_id,
            dependency_type_code,
            adjustment_time,
            adjustment_time_uom,
            object_version_number
          from   jtf_task_depends
          where  dependent_on_task_id = p_task_id and template_flag = 'Y';

      -- Cursor for finding predecessor dependencies
      cursor c_predecessor_dependency
        is
          select dependency_id,
            dependent_on_task_id,
            dependency_type_code,
            adjustment_time,
            adjustment_time_uom,
            object_version_number
          from   jtf_task_depends
          where  task_id = p_task_id and
            (template_flag is null or template_flag = 'N');


      -- Cursor for finding predecessor dependencies for template
      cursor c_pre_template_dependency
        is
          select dependency_id,
            dependent_on_task_id,
            dependency_type_code,
            adjustment_time,
            adjustment_time_uom,
            object_version_number
          from   jtf_task_depends
          where  task_id = p_task_id and template_flag = 'Y';

        parent_depend      c_predecessor_dependency%rowtype;
        child_depend       c_successor_dependency%rowtype;


    begin
      savepoint reconnect_dependency_pvt;

      if not fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name)
      then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if fnd_api.to_boolean (p_init_msg_list)
      then
        fnd_msg_pub.initialize;
      end if;
      -- Walk through parent dependencies and reconnect them with child dependencies
      for parent_depend in c_predecessor_dependency
      loop
        for child_depend in c_successor_dependency
        loop
          if (parent_depend.dependency_type_code = child_depend.dependency_type_code)
          then
            if ((parent_depend.adjustment_time is null and
                 child_depend.adjustment_time is null) or
                (parent_depend.adjustment_time is not null and
                 child_depend.adjustment_time is not null and
                 parent_depend.adjustment_time_uom =
                   child_depend.adjustment_time_uom and
                 parent_depend.adjustment_time = child_depend.adjustment_time))
            then
              jtf_task_dependency_pvt.create_task_dependency (
                  p_api_version => 1.0,
                  p_init_msg_list => fnd_api.g_false,
                  p_commit => fnd_api.g_false,
                  p_task_id => child_depend.task_id,
                  p_dependent_on_task_id => parent_depend.dependent_on_task_id,
                  p_dependency_type_code => parent_depend.dependency_type_code,
                  p_template_flag  => p_template_flag,
                  p_adjustment_time => parent_depend.adjustment_time,
                  p_adjustment_time_uom => parent_depend.adjustment_time_uom,
                  x_return_status => x_return_status,
                  x_msg_data => x_msg_data,
                  x_msg_count => x_msg_count,
                  x_dependency_id => x_dependency_id);
            end if;
          end if;
        end loop;
      end loop;

      if fnd_api.to_boolean (p_commit)
      then
        commit work;
      end if;

      exception
        when fnd_api.g_exc_error
        then
            rollback to reconnect_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        when fnd_api.g_exc_unexpected_error
        then
            rollback to reconnect_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        when no_data_found
        then
            rollback to reconnect_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_CREATING_DEPENDS');
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        when others
        then
            rollback to reconnect_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    end;


    PROCEDURE create_task_dependency (
        p_api_version            IN       NUMBER,
        p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                IN       NUMBER,
        p_dependent_on_task_id   IN       NUMBER,
        p_dependency_type_code   IN       VARCHAR2,
        p_template_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
        p_adjustment_time        IN       NUMBER DEFAULT NULL,
        p_adjustment_time_uom    IN       VARCHAR2 DEFAULT NULL,
        x_dependency_id          OUT NOCOPY      NUMBER,
        x_return_status          OUT NOCOPY      VARCHAR2,
        x_msg_data               OUT NOCOPY      VARCHAR2,
        x_msg_count              OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null ,
        p_validated_flag          in       varchar2 default 'N'
    )
    IS

        l_api_version             CONSTANT NUMBER                      := 1.0;
        l_api_name                CONSTANT VARCHAR2(30)                := 'CREATE_TASK_DEPENDENCY';
        l_dependency_id           jtf_task_depends.dependency_id%TYPE  := -1;
        l_rowid                   ROWID;
        l_d_source_object_type_code    jtf_tasks_b.source_object_type_code%TYPE;
        l_d_source_object_id           jtf_tasks_b.source_object_id%TYPE;
        l_source_object_type_code      jtf_tasks_b.source_object_type_code%TYPE;
        l_source_object_id             jtf_tasks_b.source_object_id%TYPE;

    BEGIN
        SAVEPOINT create_task_dependency_pvt;


        IF NOT fnd_api.compatible_api_call (l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Validate effort
        jtf_task_utl.validate_effort (x_return_status => x_return_status,
                                      p_effort => p_adjustment_time,
                                      p_effort_uom => p_adjustment_time_uom);

        if (x_return_status = fnd_api.g_ret_sts_error)
        then
          raise fnd_api.g_exc_error;
        elsif (x_return_status = fnd_api.g_ret_sts_unexp_error)
        then
          raise fnd_api.g_exc_unexpected_error;
        end if;

        if p_template_flag = jtf_task_utl.g_yes
        then
          if (jtf_task_utl.get_task_template_group (p_task_id) <>
              jtf_task_utl.get_task_template_group (p_dependent_on_task_id))
          then
            fnd_message.set_name ('JTF', 'JTF_TASK_INCONSISTENT_TEMP');
            fnd_message.set_token ('P_TASK_TEMPLATE_1', p_task_id);
            fnd_message.set_token ('P_TASK_TEMPLATE_2', p_dependent_on_task_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_unexpected_error;
          end if;
        else
          jtf_task_utl.get_object_details (p_task_id => p_task_id,
                                           p_template_flag => p_template_flag,
                                           x_return_status => x_return_status,
                                           x_source_object_code => l_source_object_type_code);


          if not (x_return_status = fnd_api.g_ret_sts_success)
          then
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            raise fnd_api.g_exc_unexpected_error;
          end if;

          jtf_task_utl.get_object_details (p_task_id => p_dependent_on_task_id,
                                           p_template_flag => p_template_flag,
                                           x_return_status => x_return_status,
                                           x_source_object_code => l_d_source_object_type_code);


          if (x_return_status = fnd_api.g_ret_sts_error)
          then
              raise fnd_api.g_exc_error;
          elsif (x_return_status = fnd_api.g_ret_sts_unexp_error)
          then
            raise fnd_api.g_exc_unexpected_error;
          end if;


          if ((l_source_object_type_code is null and
               l_d_source_object_type_code is not null) or
              (l_source_object_type_code is not null and
               l_d_source_object_type_code is null))
          then
              fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_TYPE_CODE');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end if;

          if (l_source_object_type_code is not null and l_d_source_object_type_code is not null)
          then
            if (l_source_object_type_code <> l_d_source_object_type_code)
            then
              fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_TYPE_CODE');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            end if;
          end if;
        end if;

        if ((validate_task_dependency ( p_task_id => p_task_id,
                                      p_dependent_on_task_id => p_dependent_on_task_id,
                                      p_dependency_id => l_dependency_id,
                                      p_template_flag => p_template_flag)
                                    = fnd_api.g_ret_sts_error) or
           (p_validated_flag = 'Y' and NVL(p_template_flag,'N') <> 'Y' and -- Added p_template_flag by SBARAT on 22/02/206 for bug# 4998404
           validate_dependency ( p_task_id => p_task_id,
                                 p_dependent_on_task_id => p_dependent_on_task_id,
                                 p_dependency_type_code => p_dependency_type_code,
                                 p_adjustment_time  => p_adjustment_time,
                                 p_adjustment_time_uom  => p_adjustment_time_uom,
                                 p_validated_flag => p_validated_flag)
                                 = fnd_api.g_ret_sts_error))
        then
            raise fnd_api.g_exc_error;
        end if;


        SELECT jtf_task_depends_s.nextval
          INTO l_dependency_id
          FROM dual;

        jtf_task_depends_pkg.insert_row (
            x_rowid => l_rowid,
            x_dependency_id => l_dependency_id,
            x_task_id => p_task_id,
            x_dependent_on_task_id => p_dependent_on_task_id,
            x_adjustment_time => p_adjustment_time,
            x_adjustment_time_uom => p_adjustment_time_uom,
            x_template_flag => p_template_flag,
            x_validated_flag => p_validated_flag,
            x_attribute1 => p_attribute1 ,
            x_attribute2 => p_attribute2 ,
            x_attribute3 => p_attribute3 ,
            x_attribute4 => p_attribute4 ,
            x_attribute5 => p_attribute5 ,
            x_attribute6 => p_attribute6 ,
            x_attribute7 => p_attribute7 ,
            x_attribute8 => p_attribute8 ,
            x_attribute9 => p_attribute9 ,
            x_attribute10 => p_attribute10 ,
            x_attribute11 => p_attribute11 ,
            x_attribute12 => p_attribute12 ,
            x_attribute13 => p_attribute13 ,
            x_attribute14 => p_attribute14 ,
            x_attribute15 => p_attribute15,
            x_attribute_category => p_attribute_category ,
            x_dependency_type_code => p_dependency_type_code,
            x_creation_date => SYSDATE,
            x_created_by => jtf_task_utl.created_by,
            x_last_update_date => SYSDATE,
            x_last_updated_by => jtf_task_utl.updated_by,
            x_last_update_login => jtf_task_utl.login_id
        );

        if fnd_api.to_boolean (p_commit)
        then
            commit work;
        end if;

        x_dependency_id := l_dependency_id;

    EXCEPTION
        -- Bug 3342398
        -- Added handle of fnd_api.g_exc_error.
        WHEN fnd_api.g_exc_error
        THEN
            ROLLBACK TO create_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO create_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN no_data_found
        THEN
            ROLLBACK TO create_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_CREATING_DEPENDS');
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO create_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

/**********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************/
    PROCEDURE update_task_dependency (
        p_api_version            IN       NUMBER,
        p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number  IN    out NOCOPY  NUMBER,
        p_dependency_id          IN       NUMBER,
        p_task_id                IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_dependent_on_task_id   IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_dependency_type_code   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_adjustment_time        IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_adjustment_time_uom    IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        x_return_status          OUT NOCOPY      VARCHAR2,
        x_msg_count              OUT NOCOPY      NUMBER,
        x_msg_data               OUT NOCOPY      VARCHAR2,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_validated_flag          in       varchar2 default 'N'
    )
    IS
        l_api_name            CONSTANT VARCHAR2(30)                               := 'UPDATE_TASK_DEPENDENCY';

        l_source_object_type_code      jtf_tasks_b.source_object_type_code%TYPE;
        l_source_object_id             jtf_tasks_b.source_object_id%TYPE;
        l_d_source_object_type_code    jtf_tasks_b.source_object_type_code%TYPE;
        l_d_source_object_id           jtf_tasks_b.source_object_id%TYPE;
        l_dependency_id                jtf_task_depends.dependency_id%TYPE        := p_dependency_id;
        l_task_id                      jtf_task_depends.task_id%TYPE              := p_task_id;
        l_dependent_on_task_id         jtf_task_depends.dependent_on_task_id%TYPE := p_dependent_on_task_id;
        l_dependency_type_code         jtf_task_depends.dependency_type_code%TYPE := p_dependency_type_code;
        l_adjustment_time              jtf_task_depends.adjustment_time%TYPE      := p_adjustment_time;
        l_adjustment_time_uom          jtf_task_depends.adjustment_time_uom%TYPE  := p_adjustment_time_uom;
        l_template_flag                jtf_task_depends.template_flag%TYPE;
        Resource_Locked exception ;

        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;


        CURSOR c_jtf_task_depends
        IS
            SELECT DECODE (p_task_id, fnd_api.g_miss_num, task_id, p_task_id) task_id,
                   DECODE (p_dependent_on_task_id, fnd_api.g_miss_num, dependent_on_task_id, p_dependent_on_task_id) dependent_on_task_id,
                   DECODE (p_dependency_type_code, fnd_api.g_miss_char, dependency_type_code, p_dependency_type_code) dependency_type_code,
                   template_flag template_flag,
                   DECODE (p_adjustment_time, fnd_api.g_miss_num, adjustment_time, p_adjustment_time) adjustment_time,
                   DECODE (p_adjustment_time_uom, fnd_api.g_miss_char, adjustment_time_uom, p_adjustment_time_uom) adjustment_time_uom,
                   created_by,
                   DECODE( p_attribute1 , fnd_api.g_miss_char , attribute1 , p_attribute1 )  attribute1  ,
                   DECODE( p_attribute2 , fnd_api.g_miss_char , attribute2 , p_attribute2 )  attribute2  ,
                   DECODE( p_attribute3 , fnd_api.g_miss_char , attribute3 , p_attribute3 )  attribute3  ,
                   DECODE( p_attribute4 , fnd_api.g_miss_char , attribute4 , p_attribute4 )  attribute4  ,
                   DECODE( p_attribute5 , fnd_api.g_miss_char , attribute5 , p_attribute5 )  attribute5  ,
                   DECODE( p_attribute6 , fnd_api.g_miss_char , attribute6 , p_attribute6 )  attribute6  ,
                   DECODE( p_attribute7 , fnd_api.g_miss_char , attribute7 , p_attribute7 )  attribute7  ,
                   DECODE( p_attribute8 , fnd_api.g_miss_char , attribute8 , p_attribute8 )  attribute8  ,
                   DECODE( p_attribute9 , fnd_api.g_miss_char , attribute9 , p_attribute9 )  attribute9  ,
                   DECODE( p_attribute10 , fnd_api.g_miss_char , attribute10 , p_attribute10 )  attribute10  ,
                   DECODE( p_attribute11 , fnd_api.g_miss_char , attribute11 , p_attribute11 )  attribute11  ,
                   DECODE( p_attribute12 , fnd_api.g_miss_char , attribute12 , p_attribute12 )  attribute12  ,
                   DECODE( p_attribute13 , fnd_api.g_miss_char , attribute13 , p_attribute13 )  attribute13  ,
                   DECODE( p_attribute14 , fnd_api.g_miss_char , attribute14 , p_attribute14 )  attribute14  ,
                   DECODE( p_attribute15 , fnd_api.g_miss_char , attribute15 , p_attribute15 )  attribute15 ,
                   DECODE( p_attribute_category,fnd_api.g_miss_char,attribute_category,p_attribute_category) attribute_category
              FROM jtf_task_depends
             WHERE dependency_id = l_dependency_id;

        task_depends                   c_jtf_task_depends%ROWTYPE;
    BEGIN
        --- This does not check between tasks and templates
        --- because it is assumed the same is validated before
        --- calling this proc.

        SAVEPOINT update_task_dependency_pvt;
        x_return_status := fnd_api.g_ret_sts_success;

        OPEN c_jtf_task_depends;
        FETCH c_jtf_task_depends INTO task_depends;

        IF c_jtf_task_depends%NOTFOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DEPENDS_ID');
            fnd_message.set_token ('P_DEPENDENCY_ID', p_dependency_id);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_template_flag := task_depends.template_flag;

        IF l_template_flag IS NULL
        THEN
            l_template_flag := jtf_task_utl.g_no;
        END IF;

        IF l_task_id = fnd_api.g_miss_num
        THEN
            l_task_id := task_depends.task_id;
        END IF;

        IF l_dependent_on_task_id = fnd_api.g_miss_num
        THEN
            l_dependent_on_task_id := task_depends.dependent_on_task_id;
        END IF;

        IF l_dependency_type_code = fnd_api.g_miss_char
        THEN
            l_dependency_type_code := task_depends.dependency_type_code;
        END IF;

        IF l_adjustment_time = fnd_api.g_miss_num
        THEN
            l_adjustment_time := task_depends.adjustment_time;
        END IF;

        IF l_adjustment_time_uom = fnd_api.g_miss_char
        THEN
            l_adjustment_time_uom := task_depends.adjustment_time_uom;
        END IF;

        -- Validate effort
        jtf_task_utl.validate_effort (x_return_status => x_return_status,
                                      p_effort => p_adjustment_time,
                                      p_effort_uom => p_adjustment_time_uom);

        if (x_return_status = fnd_api.g_ret_sts_error)
        then
          raise fnd_api.g_exc_error;
        elsif (x_return_status = fnd_api.g_ret_sts_unexp_error)
        then
          raise fnd_api.g_exc_unexpected_error;
        end if;

        if l_template_flag = jtf_task_utl.g_yes
        then
          if (jtf_task_utl.get_task_template_group (p_task_id) <>
              jtf_task_utl.get_task_template_group (p_dependent_on_task_id))
          then
            fnd_message.set_name ('JTF', 'JTF_TASK_INCONSISTENT_TEMP');
            fnd_message.set_token ('P_TASK_TEMPLATE_1', p_task_id);
            fnd_message.set_token ('P_TASK_TEMPLATE_2', p_dependent_on_task_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_unexpected_error;
          end if;
        else
          jtf_task_utl.get_object_details (p_task_id => p_task_id,
                                           p_template_flag => l_template_flag,
                                           x_return_status => x_return_status,
                                           x_source_object_code => l_source_object_type_code);


          if not (x_return_status = fnd_api.g_ret_sts_success)
          then
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            raise fnd_api.g_exc_unexpected_error;
          end if;

          jtf_task_utl.get_object_details (p_task_id => p_dependent_on_task_id,
                                           p_template_flag => l_template_flag,
                                           x_return_status => x_return_status,
                                           x_source_object_code => l_d_source_object_type_code);


          if (x_return_status = fnd_api.g_ret_sts_error)
          then
              raise fnd_api.g_exc_error;
          elsif (x_return_status = fnd_api.g_ret_sts_unexp_error)
          then
            raise fnd_api.g_exc_unexpected_error;
          end if;


          if ((l_source_object_type_code is null and
               l_d_source_object_type_code is not null) or
              (l_source_object_type_code is not null and
               l_d_source_object_type_code is null))
          then
              fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_TYPE_CODE');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end if;

          if (l_source_object_type_code is not null and l_d_source_object_type_code is not null)
          then
            if (l_source_object_type_code <> l_d_source_object_type_code)
            then
              fnd_message.set_name ('JTF', 'JTF_TASK_DEPENDS_TYPE_CODE');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
            end if;
          end if;
        end if;

        if ((validate_task_dependency ( p_task_id => p_task_id,
                                      p_dependent_on_task_id => p_dependent_on_task_id,
                                      p_dependency_id => l_dependency_id,
                                      p_template_flag => l_template_flag)
                                    = fnd_api.g_ret_sts_error) or
           (p_validated_flag = 'Y' and NVL(l_template_flag,'N') <> 'Y' and -- Added p_template_flag by SBARAT on 22/02/206 for bug# 4998404
           validate_dependency ( p_task_id => p_task_id,
                                 p_dependent_on_task_id => p_dependent_on_task_id,
                                 p_dependency_type_code => p_dependency_type_code,
                                 p_adjustment_time  => p_adjustment_time,
                                 p_adjustment_time_uom  => p_adjustment_time_uom,
                                 p_validated_flag => p_validated_flag)
                                 = fnd_api.g_ret_sts_error))
        then
            raise fnd_api.g_exc_error;
        end if;


        jtf_task_depends_pkg.lock_row(
            x_dependency_id => p_dependency_id ,
            x_object_version_number => p_object_version_number  );


        jtf_task_depends_pkg.update_row (
            x_dependency_id => l_dependency_id,
            x_object_version_number => p_object_version_number + 1,
            x_task_id => l_task_id,
            x_dependent_on_task_id => l_dependent_on_task_id,
            x_dependency_type_code => l_dependency_type_code,
            x_adjustment_time_uom => l_adjustment_time_uom,
            x_template_flag => l_template_flag,
            x_adjustment_time => l_adjustment_time,
            x_validated_flag => p_validated_flag,
            x_attribute1 => task_depends.attribute1 ,
            x_attribute2 => task_depends.attribute2 ,
            x_attribute3 => task_depends.attribute3 ,
            x_attribute4 => task_depends.attribute4 ,
            x_attribute5 => task_depends.attribute5 ,
            x_attribute6 => task_depends.attribute6 ,
            x_attribute7 => task_depends.attribute7 ,
            x_attribute8 => task_depends.attribute8 ,
            x_attribute9 => task_depends.attribute9 ,
            x_attribute10 => task_depends.attribute10 ,
            x_attribute11 => task_depends.attribute11 ,
            x_attribute12 => task_depends.attribute12 ,
            x_attribute13 => task_depends.attribute13 ,
            x_attribute14 => task_depends.attribute14 ,
            x_attribute15 => task_depends.attribute15 ,
            x_attribute_category => task_depends.attribute_category ,
            x_last_update_date => SYSDATE,
            x_last_updated_by => jtf_task_utl.updated_by,
            x_last_update_login => -1
        );

        IF c_jtf_task_depends%ISOPEN
        THEN
            CLOSE c_jtf_task_depends;
        END IF;

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        p_object_version_number := p_object_version_number + 1;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        /*
          Bug 3342398
          Added handle of fnd_api.g_exc_error.
        */
        WHEN fnd_api.g_exc_error
        THEN
            ROLLBACK TO update_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;
            ROLLBACK TO update_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN no_data_found
        THEN
            ROLLBACK TO create_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_CREATING_DEPENDS');
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN Resource_Locked then
            ROLLBACK TO lock_task_depends_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            IF c_jtf_task_depends%ISOPEN
            THEN
                CLOSE c_jtf_task_depends;
            END IF;

            ROLLBACK TO update_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

/**********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************/
    PROCEDURE delete_task_dependency (
        p_api_version     IN       NUMBER,
        p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number  IN NUMBER,
        p_dependency_id   IN       NUMBER,
        x_return_status   OUT NOCOPY      VARCHAR2,
        x_msg_count       OUT NOCOPY      NUMBER,
        x_msg_data        OUT NOCOPY      VARCHAR2
    )
    IS
        x                char;
        l_dependency_id    jtf_task_depends.dependency_id%TYPE := p_dependency_id;
        Resource_Locked exception ;
        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;


        CURSOR c_jtf_task_depends
        IS
            SELECT 1
              FROM jtf_task_depends
             WHERE dependency_id = l_dependency_id;
    BEGIN
        --- This does not check between tasks and templates
        --- because it is assumed the same is validated before
        --- calling this proc,
        SAVEPOINT delete_task_dependency_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        jtf_task_depends_pkg.lock_row(
            x_dependency_id => p_dependency_id ,
            x_object_version_number => p_object_version_number  );

        jtf_task_depends_pkg.delete_row (x_dependency_id => l_dependency_id);
        OPEN c_jtf_task_depends;
        FETCH c_jtf_task_depends INTO x;

        IF c_jtf_task_depends%FOUND
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_DELETING_DEPEND');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
            CLOSE c_jtf_task_depends;
        ELSE
            CLOSE c_jtf_task_depends;
        END IF;

        IF c_jtf_task_depends%ISOPEN
        THEN
            CLOSE c_jtf_task_depends;
        END IF;

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        /*
          Bug 3342398
          Added handle of fnd_api.g_exc_error.
        */
        WHEN fnd_api.g_exc_error
        THEN
            ROLLBACK TO delete_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO delete_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN Resource_Locked then
            ROLLBACK TO lock_task_depends_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO delete_task_dependency_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;
END;   -- CREATE OR REPLACE PACKAGE spec

/
