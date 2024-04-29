--------------------------------------------------------
--  DDL for Package Body JTF_TASK_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_RESOURCES_PUB" AS
  /* $Header: jtfptkrb.pls 120.1.12000000.3 2007/08/06 12:14:22 rkamasam ship $ */
  PROCEDURE create_task_rsrc_req(
    p_api_version        IN            NUMBER
  , p_init_msg_list      IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit             IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_task_id            IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name          IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_number        IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_type_id       IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_type_name     IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_task_template_id   IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_template_name IN            VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_resource_type_code IN            VARCHAR2
  , p_required_units     IN            NUMBER
  , p_enabled_flag       IN            VARCHAR2 DEFAULT jtf_task_utl.g_no
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , x_resource_req_id    OUT NOCOPY    NUMBER
  , p_attribute1         IN            VARCHAR2 DEFAULT NULL
  , p_attribute2         IN            VARCHAR2 DEFAULT NULL
  , p_attribute3         IN            VARCHAR2 DEFAULT NULL
  , p_attribute4         IN            VARCHAR2 DEFAULT NULL
  , p_attribute5         IN            VARCHAR2 DEFAULT NULL
  , p_attribute6         IN            VARCHAR2 DEFAULT NULL
  , p_attribute7         IN            VARCHAR2 DEFAULT NULL
  , p_attribute8         IN            VARCHAR2 DEFAULT NULL
  , p_attribute9         IN            VARCHAR2 DEFAULT NULL
  , p_attribute10        IN            VARCHAR2 DEFAULT NULL
  , p_attribute11        IN            VARCHAR2 DEFAULT NULL
  , p_attribute12        IN            VARCHAR2 DEFAULT NULL
  , p_attribute13        IN            VARCHAR2 DEFAULT NULL
  , p_attribute14        IN            VARCHAR2 DEFAULT NULL
  , p_attribute15        IN            VARCHAR2 DEFAULT NULL
  , p_attribute_category IN            VARCHAR2 DEFAULT NULL
  ) IS
    --Declare the variables
    l_api_version CONSTANT NUMBER                                       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                                 := 'CREATE_TASK_RSRC_REQ';
    l_return_status        VARCHAR2(1)                                  := fnd_api.g_ret_sts_success;
    l_task_id              jtf_tasks_b.task_id%TYPE                     := p_task_id;
    l_task_number          jtf_tasks_b.task_number%TYPE                 := p_task_number;
    l_task_name            jtf_tasks_tl.task_name%TYPE                  := p_task_name;
    l_task_type_id         jtf_task_types_b.task_type_id%TYPE           := p_task_type_id;
    l_task_type_name       jtf_task_types_tl.NAME%TYPE                  := p_task_type_name;
    l_task_template_id     jtf_task_templates_b.task_template_id%TYPE   := p_task_template_id;
    l_task_template_name   jtf_task_templates_tl.task_name%TYPE         := p_task_template_name;
    l_enabled_flag         jtf_task_rsc_reqs.enabled_flag%TYPE          := p_enabled_flag;
    l_resource_type_code   jtf_task_rsc_reqs.resource_type_code%TYPE    := p_resource_type_code;
    l_required_units       jtf_task_rsc_reqs.required_units%TYPE        := p_required_units;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    x                      CHAR;
  --
  BEGIN
    SAVEPOINT create_task_rsrc_req;

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --Check for Required Parameters
    --Resource subtype
    IF l_resource_type_code IS NULL THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('JTF', 'JTF_TASK_NULL_RES_TYPE_CODE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Required Units
    IF l_required_units IS NULL THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('JTF', 'JTF_TASK_NULL_REQ_UNIT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --- Validate enabled flag
    jtf_task_utl.validate_flag(
      p_api_name                   => l_api_name
    , p_init_msg_list              => fnd_api.g_false
    , x_return_status              => l_return_status
    , p_flag_name                  => 'Enabled_Flag'
    , p_flag_value                 => l_enabled_flag
    );

    IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INVALID_FLAG');
      fnd_message.set_token('ENABLED_FLAG', p_enabled_flag);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ---- if Enabled flag is null,Task is not Active

    --Validations for Task_id ,Task_template_id and task_type _id
    --based on the status of P_ENABLED_FLAG
    IF l_enabled_flag IN(jtf_task_utl.g_yes, jtf_task_utl.g_no) THEN
      IF (p_task_template_id <> fnd_api.g_miss_num OR p_task_template_name <> fnd_api.g_miss_char) THEN
        SELECT DECODE(p_task_template_id, fnd_api.g_miss_num, NULL, p_task_template_id)
          INTO l_task_template_id
          FROM DUAL;

        jtf_task_resources_pvt.validate_task_template(
          x_return_status              => l_return_status
        , p_task_template_id           => l_task_template_id
        , p_task_name                  => l_task_template_name
        , x_task_template_id           => l_task_template_id
        , x_task_name                  => l_task_template_name
        );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSIF(
               p_task_id <> fnd_api.g_miss_num
            OR p_task_name <> fnd_api.g_miss_char
            OR p_task_number <> fnd_api.g_miss_char
           ) THEN
        SELECT DECODE(p_task_id, fnd_api.g_miss_num, NULL, p_task_id)
          INTO l_task_id
          FROM DUAL;

        SELECT DECODE(p_task_number, fnd_api.g_miss_char, NULL, p_task_number)
          INTO l_task_number
          FROM DUAL;

        jtf_task_utl.validate_task(
          x_return_status              => l_return_status
        , p_task_id                    => l_task_id
        , p_task_number                => l_task_number
        , x_task_id                    => l_task_id
        );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_task_id IS NULL THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
          fnd_message.set_token('TASK_ID', p_task_id);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSIF(p_task_type_id <> fnd_api.g_miss_num OR p_task_type_name <> fnd_api.g_miss_char) THEN
        SELECT DECODE(p_task_type_id, fnd_api.g_miss_num, NULL, p_task_type_id)
          INTO l_task_type_id
          FROM DUAL;

        SELECT DECODE(p_task_type_name, fnd_api.g_miss_char, NULL, p_task_type_name)
          INTO l_task_type_name
          FROM DUAL;

        jtf_task_resources_pvt.validate_task_type(
          x_return_status              => l_return_status
        , p_task_type_id               => l_task_type_id
        , p_name                       => l_task_type_name
        , x_task_type_id               => l_task_type_id
        , x_task_name                  => l_task_type_name
        );

        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF l_task_type_id IS NULL THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TYPE_ID');
          fnd_message.set_token('TASK_ID', p_task_type_id);
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSIF (l_task_template_id IS NULL) AND(l_task_id IS NULL) AND(l_task_type_id IS NULL) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('JTF', 'JTF_TASK_INV_INPUT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF     (l_task_template_id IS NOT NULL)
            AND (l_task_id IS NOT NULL)
            AND (l_task_type_id IS NOT NULL) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('JTF', 'JTF_TASK_INV_INPUT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (l_task_template_id IS NOT NULL) AND(l_task_id IS NOT NULL) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('JTF', 'JTF_TASK_INV_INPUT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (l_task_id IS NOT NULL) AND(l_task_type_id IS NOT NULL) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('JTF', 'JTF_TASK_INV_INPUT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (l_task_template_id IS NOT NULL) AND(l_task_type_id IS NOT NULL) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('JTF', 'JTF_TASK_INV_INPUT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF NOT jtf_task_resources_pvt.validate_resource_type_code(p_resource_type_code => l_resource_type_code) THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INV_RES_TYP_COD');
        fnd_message.set_token('RESOURCE_CODE', p_resource_type_code);
        --fnd_msg.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INV_RES_TYP_COD');
        fnd_message.set_token('RESOURCE_CODE', p_resource_type_code);
        --fnd_msg.add;
        RAISE fnd_api.g_exc_error;
      ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        fnd_message.set_name('JTF', 'JTF_TASK_INV_RES_TYP_COD');
        fnd_message.set_token('RESOURCE_CODE', p_resource_type_code);
        --fnd_msg.add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --Call to private API to insert into JTF_TASK_RESOURCE_REQ
      jtf_task_resources_pvt.create_task_rsrc_req(
        p_api_version                => l_api_version
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => l_task_id
      , p_task_name                  => l_task_name
      , p_task_number                => l_task_number
      , p_task_type_id               => l_task_type_id
      , p_task_type_name             => l_task_name
      , p_task_template_id           => l_task_template_id
      , p_task_template_name         => l_task_template_name
      , p_resource_type_code         => l_resource_type_code
      , p_required_units             => l_required_units
      , p_enabled_flag               => l_enabled_flag
      , x_return_status              => l_return_status
      , x_msg_data                   => l_msg_data
      , x_msg_count                  => l_msg_count
      , x_resource_req_id            => x_resource_req_id
      , p_attribute1                 => p_attribute1
      , p_attribute2                 => p_attribute2
      , p_attribute3                 => p_attribute3
      , p_attribute4                 => p_attribute4
      , p_attribute5                 => p_attribute5
      , p_attribute6                 => p_attribute6
      , p_attribute7                 => p_attribute7
      , p_attribute8                 => p_attribute8
      , p_attribute9                 => p_attribute9
      , p_attribute10                => p_attribute10
      , p_attribute11                => p_attribute11
      , p_attribute12                => p_attribute12
      , p_attribute13                => p_attribute13
      , p_attribute14                => p_attribute14
      , p_attribute15                => p_attribute15
      , p_attribute_category         => p_attribute_category
      );
    END IF;

    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_task_rsrc_req;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_task_rsrc_req;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_task_rsrc_req;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      /*        if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
              then
                  fnd_msg_pub.add_exc_msg(g_pkg_name,l_api_name) ;
              end if ;*/
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  --Procedure to Update the Task Resource Requirements
  PROCEDURE update_task_rscr_req(
    p_api_version           IN            NUMBER
  , p_object_version_number IN OUT NOCOPY NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_resource_req_id       IN            NUMBER
  , p_task_id               IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_name             IN            VARCHAR2 DEFAULT NULL
  , p_task_number           IN            VARCHAR2 DEFAULT NULL
  , p_task_type_id          IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_type_name        IN            VARCHAR2 DEFAULT NULL
  , p_task_template_id      IN            NUMBER DEFAULT fnd_api.g_miss_num
  , p_task_template_name    IN            VARCHAR2 DEFAULT NULL
  , p_resource_type_code    IN            VARCHAR2
  , p_required_units        IN            NUMBER
  , p_enabled_flag          IN            VARCHAR2 DEFAULT jtf_task_utl.g_no
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_attribute1            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute2            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute3            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute4            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute5            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute6            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute7            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute8            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute9            IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute10           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute11           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute12           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute13           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute14           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute15           IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  , p_attribute_category    IN            VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
  ) IS
    l_api_version CONSTANT NUMBER                                       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                                 := 'UPDATE_TASK_RSRC_REQ';
    l_return_status        VARCHAR2(1)                                 := fnd_api.g_ret_sts_success;
    l_task_id              jtf_tasks_b.task_id%TYPE                     := p_task_id;
    l_task_number          jtf_tasks_b.task_number%TYPE                 := p_task_number;
    l_task_name            jtf_tasks_tl.task_name%TYPE                  := p_task_name;
    l_task_type_id         jtf_task_types_b.task_type_id%TYPE           := p_task_type_id;
    l_task_type_name       jtf_task_types_tl.NAME%TYPE                  := p_task_type_name;
    l_task_template_id     jtf_task_templates_b.task_template_id%TYPE   := p_task_template_id;
    l_task_template_name   jtf_task_templates_tl.task_name%TYPE         := p_task_template_name;
    l_enabled_flag         jtf_task_rsc_reqs.enabled_flag%TYPE          := p_enabled_flag;
    l_resource_type_code   jtf_task_rsc_reqs.resource_type_code%TYPE    := p_resource_type_code;
    l_required_units       jtf_task_rsc_reqs.required_units%TYPE        := p_required_units;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    x                      CHAR;
    l_resource_req_id      NUMBER                                       := p_resource_req_id;
    l_rowid                ROWID;

    CURSOR jtf_rsrc_req_cur IS
      SELECT DECODE(p_task_id, fnd_api.g_miss_num, task_id, p_task_id) task_id
           , DECODE(p_task_template_id, fnd_api.g_miss_num, task_template_id, p_task_template_id)
                                                                                   task_template_id
           , p_task_type_id task_type_id
           , p_resource_type_code resource_type_code
           , p_required_units required_units
           , enabled_flag
           , DECODE(p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1) attribute1
           , DECODE(p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2) attribute2
           , DECODE(p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3) attribute3
           , DECODE(p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4) attribute4
           , DECODE(p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5) attribute5
           , DECODE(p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6) attribute6
           , DECODE(p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7) attribute7
           , DECODE(p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8) attribute8
           , DECODE(p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9) attribute9
           , DECODE(p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10) attribute10
           , DECODE(p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11) attribute11
           , DECODE(p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12) attribute12
           , DECODE(p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13) attribute13
           , DECODE(p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14) attribute14
           , DECODE(p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15) attribute15
           , DECODE(
               p_attribute_category
             , fnd_api.g_miss_char, attribute_category
             , p_attribute_category
             ) attribute_category
        FROM jtf_task_rsc_reqs
       WHERE resource_req_id = p_resource_req_id;

    task_rsrc_req_rec      jtf_rsrc_req_cur%ROWTYPE;
  BEGIN
    SAVEPOINT update_task_rsrc_req;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- check if the resource requirement is invalid or null.
    IF (l_resource_req_id IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_NULL_RES_REQ_ID');
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    OPEN jtf_rsrc_req_cur;

    FETCH jtf_rsrc_req_cur
     INTO task_rsrc_req_rec;

    IF jtf_rsrc_req_cur%NOTFOUND THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INV_RES_REQ_ID');
      fnd_message.set_token('RESOURCE_REQ_ID', p_resource_req_id);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ---enabled_flag
    l_enabled_flag   := task_rsrc_req_rec.enabled_flag;

    --- Validating for the task
    IF NOT(p_task_id = fnd_api.g_miss_num AND p_task_number = fnd_api.g_miss_char) THEN
      SELECT DECODE(p_task_id, fnd_api.g_miss_num, NULL, p_task_id)
        INTO l_task_id
        FROM DUAL;

      SELECT DECODE(p_task_number, fnd_api.g_miss_char, NULL, p_task_number)
        INTO l_task_number
        FROM DUAL;

      IF (l_enabled_flag = fnd_api.g_true) THEN
        ---- Here the task id is assigned null, if the task id is NOT input,
        ---  because then task number could be input.

        --- This means task id is being updated.
        jtf_task_utl.validate_task(
          x_return_status              => l_return_status
        , p_task_id                    => l_task_id
        , p_task_number                => l_task_number
        , x_task_id                    => l_task_id
        );
      ELSE
        jtf_task_utl.validate_task_template(
          x_return_status              => l_return_status
        , p_task_id                    => l_task_template_id
        , p_task_number                => NULL
        , x_task_id                    => l_task_template_id
        );
      END IF;

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_task_id IS NULL THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('JTF', 'JTF_TASK_INVALID_TASK_ID');
        fnd_message.set_token('TASK_ID', p_task_id);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      l_task_id  := task_rsrc_req_rec.task_id;
    END IF;

    jtf_task_resources_pub.lock_task_resources(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_resource_requirement_id    => l_resource_req_id
    , p_object_version_number      => p_object_version_number
    , x_return_status              => x_return_status
    , x_msg_data                   => x_msg_data
    , x_msg_count                  => x_msg_count
    );

    IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    jtf_task_resources_pvt.update_task_rscr_req
                                       (
      p_api_version                => 1.0
    , p_object_version_number      => p_object_version_number
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , p_resource_req_id            => l_resource_req_id
    , p_task_id                    => l_task_id
    , p_task_name                  => l_task_name
    , p_task_number                => NULL
    , p_task_type_id               => l_task_type_id
    , p_task_type_name             => NULL
    , p_task_template_id           => l_task_template_id
    , p_task_template_name         => NULL
    , p_resource_type_code         => l_resource_type_code
    , p_required_units             => l_required_units
    , p_enabled_flag               => l_enabled_flag
    , x_return_status              => l_return_status
    , x_msg_data                   => l_msg_data
    , x_msg_count                  => l_msg_count
    , p_attribute1                 => task_rsrc_req_rec.attribute1
    , p_attribute2                 => task_rsrc_req_rec.attribute2
    , p_attribute3                 => task_rsrc_req_rec.attribute3
    , p_attribute4                 => task_rsrc_req_rec.attribute4
    , p_attribute5                 => task_rsrc_req_rec.attribute5
    , p_attribute6                 => task_rsrc_req_rec.attribute6
    , p_attribute7                 => task_rsrc_req_rec.attribute7
    , p_attribute8                 => task_rsrc_req_rec.attribute8
    , p_attribute9                 => task_rsrc_req_rec.attribute9
    , p_attribute10                => task_rsrc_req_rec.attribute10
    , p_attribute11                => task_rsrc_req_rec.attribute11
    , p_attribute12                => task_rsrc_req_rec.attribute12
    , p_attribute13                => task_rsrc_req_rec.attribute13
    , p_attribute14                => task_rsrc_req_rec.attribute14
    , p_attribute15                => task_rsrc_req_rec.attribute15
    , p_attribute_category         => task_rsrc_req_rec.attribute_category
    );

    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    IF jtf_rsrc_req_cur%ISOPEN THEN
      CLOSE jtf_rsrc_req_cur;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_task_rsrc_req;

      IF jtf_rsrc_req_cur%ISOPEN THEN
        CLOSE jtf_rsrc_req_cur;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_task_rsrc_req;

      IF jtf_rsrc_req_cur%ISOPEN THEN
        CLOSE jtf_rsrc_req_cur;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_task_rsrc_req;

      IF jtf_rsrc_req_cur%ISOPEN THEN
        CLOSE jtf_rsrc_req_cur;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  --Procedure to Delete the Task Resource Requirements
  PROCEDURE delete_task_rsrc_req(
    p_api_version           IN            NUMBER
  , p_object_version_number IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_resource_req_id       IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_api_version CONSTANT NUMBER                                   := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                             := 'DELETE_TASK_RSRC_REQ';
    l_return_status        VARCHAR2(1)                              := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_resource_req_id      jtf_task_rsc_reqs.resource_req_id%TYPE   := p_resource_req_id;

    CURSOR jtf_task_rsc_req_u_cur IS
      SELECT 1
        FROM jtf_task_rsc_reqs
       WHERE resource_req_id = l_resource_req_id;

    x                      CHAR;
  BEGIN
    SAVEPOINT delete_task_rsrc_req;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    ---- if resource req is null, then it is an error
    IF (l_resource_req_id IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TASK_DELETING_RES_REQ_ID');
      fnd_message.set_token('RESOURCE_REQ_ID', p_resource_req_id);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ---- if resource req is NOT valid, then it is an error
    OPEN jtf_task_rsc_req_u_cur;

    FETCH jtf_task_rsc_req_u_cur
     INTO x;

    IF jtf_task_rsc_req_u_cur%NOTFOUND THEN
      fnd_message.set_name('JTF', 'JTF_TASK_INV_RES_REQ_ID');
      fnd_message.set_token('TASK_ID', p_resource_req_id);
      fnd_msg_pub.ADD;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      jtf_task_resources_pub.lock_task_resources
                                               (
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_resource_requirement_id    => l_resource_req_id
      , p_object_version_number      => p_object_version_number
      , x_return_status              => x_return_status
      , x_msg_data                   => x_msg_data
      , x_msg_count                  => x_msg_count
      );

      IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      jtf_task_resources_pvt.delete_task_rsrc_req
                                                (
        p_api_version                => l_api_version
      , p_object_version_number      => p_object_version_number
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , p_resource_req_id            => l_resource_req_id
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSIF(l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF jtf_task_rsc_req_u_cur%ISOPEN THEN
      CLOSE jtf_task_rsc_req_u_cur;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO delete_task_rsrc_req;

      IF jtf_task_rsc_req_u_cur%ISOPEN THEN
        CLOSE jtf_task_rsc_req_u_cur;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO delete_task_rsrc_req;

      IF jtf_task_rsc_req_u_cur%ISOPEN THEN
        CLOSE jtf_task_rsc_req_u_cur;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_task_rsrc_req;

      IF jtf_task_rsc_req_u_cur%ISOPEN THEN
        CLOSE jtf_task_rsc_req_u_cur;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  --Procedure to get the Task Resource Req
  PROCEDURE get_task_rsrc_req(
    p_api_version        IN            NUMBER
  , p_init_msg_list      IN            VARCHAR2 DEFAULT g_false
  , p_commit             IN            VARCHAR2 DEFAULT g_false
  , p_resource_req_id    IN            NUMBER
  , p_resource_req_name  IN            VARCHAR2 DEFAULT NULL
  , p_task_id            IN            NUMBER DEFAULT NULL
  , p_task_name          IN            VARCHAR2 DEFAULT NULL
  , p_task_type_id       IN            NUMBER DEFAULT NULL
  , p_task_type_name     IN            VARCHAR2 DEFAULT NULL
  , p_task_template_id   IN            NUMBER DEFAULT NULL
  , p_task_template_name IN            VARCHAR2 DEFAULT NULL
  , p_sort_data          IN            jtf_task_resources_pub.sort_data
  , p_query_or_next_code IN            VARCHAR2 DEFAULT 'Q'
  , p_start_pointer      IN            NUMBER
  , p_rec_wanted         IN            NUMBER
  , p_show_all           IN            VARCHAR2 DEFAULT 'Y'
  , p_resource_type_code IN            VARCHAR2
  , p_required_units     IN            NUMBER
  , p_enabled_flag       IN            VARCHAR2 DEFAULT jtf_task_utl.g_no
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , x_task_rsc_req_rec   OUT NOCOPY    jtf_task_resources_pub.task_rsc_req_tbl
  , x_total_retrieved    OUT NOCOPY    NUMBER
  , x_total_returned     OUT NOCOPY    NUMBER
  ) IS
    l_api_version CONSTANT NUMBER                                    := 1.0;
    l_api_name    CONSTANT VARCHAR2(30)                              := 'GET_TASK_RSRC_REQ';
    l_return_status        VARCHAR2(1)                               := fnd_api.g_ret_sts_success;
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_resource_type_code   jtf_task_rsc_reqs.resource_type_code%TYPE := p_resource_type_code;
    l_task_id              jtf_task_rsc_reqs.task_id%TYPE            := p_task_id;
    l_task_type_id         jtf_task_rsc_reqs.task_type_id%TYPE       := p_task_type_id;
    l_task_template_id     jtf_task_rsc_reqs.task_template_id%TYPE   := p_task_template_id;
    l_required_units       NUMBER                                    := p_required_units;
    l_enabled_flag         VARCHAR2(1)                               := p_enabled_flag;
    l_task_name            VARCHAR2(80)                              := p_task_name;
    l_task_type_name       VARCHAR2(30)                              := p_task_type_name;
    l_task_template_name   VARCHAR2(80)                              := p_task_template_name;
    l_resource_req_id      jtf_task_rsc_reqs.resource_req_id%TYPE    := p_resource_req_id;
  BEGIN
    SAVEPOINT get_task_rsrc_req;
    x_return_status  := fnd_api.g_ret_sts_success;

    -- standard call to check for call compatibility
    IF (NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list i p_init_msg_list is set to true
    IF (fnd_api.to_boolean(p_init_msg_list)) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- required parameters to control records returned

    -- p_query_or_next_code should be Q or N
    IF (p_query_or_next_code NOT IN('Q', 'N')) OR(p_query_or_next_code IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_INV_QRY_NXT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- p_show_all should be Y or N
    IF (p_show_all NOT IN('Y', 'N')) OR(p_show_all IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_TK_INV_SHOW_ALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_show_all = 'N') THEN
      IF (p_start_pointer IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_NULL_STRT_PTR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_rec_wanted IS NULL) THEN
        fnd_message.set_name('JTF', 'JTF_TK_NULL_REC_WANT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    jtf_task_resources_pvt.get_task_rsrc_req(
      p_api_version
    , p_init_msg_list
    , p_commit
    , p_resource_req_id
    , p_resource_req_name
    , p_task_id
    , p_task_name
    , p_task_type_id
    , p_task_type_name
    , p_task_template_id
    , p_task_template_name
    , p_sort_data
    , p_query_or_next_code
    , p_start_pointer
    , p_rec_wanted
    , p_show_all
    , p_resource_type_code
    , p_required_units
    , p_enabled_flag
    , x_return_status
    , x_msg_count
    , x_msg_data
    , x_task_rsc_req_rec
    , x_total_retrieved
    , x_total_returned
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO get_task_rsrc_req;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO get_task_rsrc_req;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO get_task_rsrc_req;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE lock_task_resources(
    p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit                  IN            VARCHAR2 DEFAULT fnd_api.g_false
  , p_resource_requirement_id IN            NUMBER
  , p_object_version_number   IN            NUMBER
  , x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'LOCK_TASK_RESOURCES';
    resource_locked        EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_locked, -54);
  BEGIN
    SAVEPOINT lock_task_resources_pub;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    jtf_task_rsc_reqs_pkg.lock_row(
      x_resource_req_id            => p_resource_requirement_id
    , x_object_version_number      => p_object_version_number
    );
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN resource_locked THEN
      ROLLBACK TO lock_task_resources_pub;
      fnd_message.set_name('JTF', 'JTF_TASK_RESOURCE_LOCKED');
      fnd_message.set_token('P_LOCKED_RESOURCE', 'Resources');
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO lock_task_resources_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO lock_task_resources_pub;
      fnd_message.set_name('JTF', 'JTF_TASK_UNKNOWN_ERROR');
      fnd_message.set_token('P_TEXT', SQLCODE || SQLERRM);
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;
END;

/
