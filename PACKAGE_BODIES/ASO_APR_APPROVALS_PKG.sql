--------------------------------------------------------
--  DDL for Package Body ASO_APR_APPROVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_APPROVALS_PKG" AS
  /*  $Header: asotappb.pls 120.1 2005/06/29 12:38:34 appldev ship $ */
  -- Start of Comments
  -- Package name     : ASO_APR_APPROVALS_PKG
  -- Purpose          :
  -- History          :
  -- NOTE             :
  -- End of Comments


  g_pkg_name           CONSTANT VARCHAR2 (3000) := 'ASO_APR_APPROVALS_PKG';
  g_file_name          CONSTANT VARCHAR2 (1000) := 'asotappb.pls';

  PROCEDURE header_insert_row (
    px_object_approval_id       IN OUT NOCOPY /* file.sql.39 change */     NUMBER,
    p_object_id                          NUMBER,
    p_object_type                        VARCHAR2,
    p_approval_instance_id               NUMBER,
    p_approval_status                    VARCHAR2,
    p_application_id                     NUMBER,
    p_start_date                         DATE,
    p_end_date                           DATE,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER,
    p_requester_userid                   NUMBER,
    p_requester_comments                 VARCHAR2,
    p_requester_group_id                 NUMBER
  ) IS
    CURSOR c2 IS
      SELECT aso_apr_obj_header_s.NEXTVAL
      FROM sys.DUAL;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Header_Insert_Row procedure  ',
        1,
        'N'
      );
    END IF;
    OPEN c2;
    FETCH c2 INTO px_object_approval_id;
    CLOSE c2;

    INSERT INTO aso_apr_obj_approvals
     (object_approval_id,
      object_id,
      object_type,
      approval_instance_id,
      approval_status,
      application_id,
      start_date,
      end_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
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
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      CONTEXT,
      security_group_id,
      object_version_number,
      requester_userid,
      requester_comments,
      requester_group_id)
    VALUES (px_object_approval_id,
            DECODE (
              p_object_id,
              fnd_api.g_miss_num,
              NULL,
              p_object_id
            ),
            DECODE (
              p_object_type,
              fnd_api.g_miss_char,
              NULL,
              p_object_type
            ),
            DECODE (
              p_approval_instance_id,
              fnd_api.g_miss_num,
              NULL,
              p_approval_instance_id
            ),
            DECODE (
              p_approval_status,
              fnd_api.g_miss_char,
              NULL,
              p_approval_status
            ),
            DECODE (
              p_application_id,
              fnd_api.g_miss_num,
              NULL,
              p_application_id
            ),
            aso_utility_pvt.DECODE (
              p_start_date,
              fnd_api.g_miss_date,
              NULL,
              p_start_date
            ),
            aso_utility_pvt.DECODE (
              p_end_date,
              fnd_api.g_miss_date,
              NULL,
              p_end_date
            ),
            aso_utility_pvt.DECODE (
              p_creation_date,
              fnd_api.g_miss_date,
              NULL,
              p_creation_date
            ),
            DECODE (
              p_created_by,
              fnd_api.g_miss_num,
              NULL,
              p_created_by
            ),
            aso_utility_pvt.DECODE (
              p_last_update_date,
              fnd_api.g_miss_date,
              NULL,
              p_last_update_date
            ),
            DECODE (
              p_last_updated_by,
              fnd_api.g_miss_num,
              NULL,
              p_last_updated_by
            ),
            DECODE (
              p_last_update_login,
              fnd_api.g_miss_num,
              NULL,
              p_last_update_login
            ),
            DECODE (
              p_attribute1,
              fnd_api.g_miss_char,
              NULL,
              p_attribute1
            ),
            DECODE (
              p_attribute2,
              fnd_api.g_miss_char,
              NULL,
              p_attribute2
            ),
            DECODE (
              p_attribute3,
              fnd_api.g_miss_char,
              NULL,
              p_attribute3
            ),
            DECODE (
              p_attribute4,
              fnd_api.g_miss_char,
              NULL,
              p_attribute4
            ),
            DECODE (
              p_attribute5,
              fnd_api.g_miss_char,
              NULL,
              p_attribute5
            ),
            DECODE (
              p_attribute6,
              fnd_api.g_miss_char,
              NULL,
              p_attribute6
            ),
            DECODE (
              p_attribute7,
              fnd_api.g_miss_char,
              NULL,
              p_attribute7
            ),
            DECODE (
              p_attribute8,
              fnd_api.g_miss_char,
              NULL,
              p_attribute8
            ),
            DECODE (
              p_attribute9,
              fnd_api.g_miss_char,
              NULL,
              p_attribute9
            ),
            DECODE (
              p_attribute10,
              fnd_api.g_miss_char,
              NULL,
              p_attribute10
            ),
            DECODE (
              p_attribute11,
              fnd_api.g_miss_char,
              NULL,
              p_attribute11
            ),
            DECODE (
              p_attribute12,
              fnd_api.g_miss_char,
              NULL,
              p_attribute12
            ),
            DECODE (
              p_attribute13,
              fnd_api.g_miss_char,
              NULL,
              p_attribute13
            ),
            DECODE (
              p_attribute14,
              fnd_api.g_miss_char,
              NULL,
              p_attribute14
            ),
            DECODE (
              p_attribute15,
              fnd_api.g_miss_char,
              NULL,
              p_attribute15
            ),
            DECODE (
              p_attribute16,
              fnd_api.g_miss_char,
              NULL,
              p_attribute16
            ),
            DECODE (
              p_attribute17,
              fnd_api.g_miss_char,
              NULL,
              p_attribute17
            ),
            DECODE (
              p_attribute18,
              fnd_api.g_miss_char,
              NULL,
              p_attribute18
            ),
            DECODE (
              p_attribute19,
              fnd_api.g_miss_char,
              NULL,
              p_attribute19
            ),
            DECODE (
              p_attribute20,
              fnd_api.g_miss_char,
              NULL,
              p_attribute20
            ),
            DECODE (
              p_context,
              fnd_api.g_miss_char,
              NULL,
              p_context
            ),
            DECODE (
              p_security_group_id,
              fnd_api.g_miss_num,
              NULL,
              p_security_group_id
            ),
            DECODE (
              p_object_version_number,
              fnd_api.g_miss_num,
              NULL,
              p_object_version_number
            ),
            DECODE (
              p_requester_userid,
              fnd_api.g_miss_num,
              NULL,
              p_requester_userid
            ),
            DECODE (
              p_requester_comments,
              fnd_api.g_miss_char,
              NULL,
              p_requester_comments
            ),
            DECODE (
              p_requester_group_id,
              fnd_api.g_miss_num,
              NULL,
              p_requester_group_id
            ));

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Header_Insert_Row procedure  ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in  Header_Insert_Row procedure  ',
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'errmsg is  ' || SUBSTR (
                             SQLERRM,
                             1,
                             250
                           ),
          1,
          'N'
        );
      END IF;
  END header_insert_row;

  PROCEDURE header_update_row (
    p_object_approval_id                 NUMBER,
    p_object_id                          NUMBER,
    p_object_type                        VARCHAR2,
    p_approval_instance_id               NUMBER,
    p_approval_status                    VARCHAR2,
    p_application_id                     NUMBER,
    p_start_date                         DATE,
    p_end_date                           DATE,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER,
    p_requester_userid                   NUMBER,
    p_requester_comments                 VARCHAR2,
    p_requester_group_id                 NUMBER
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Header_Update_Row procedure  ',
        1,
        'N'
      );
    END IF;

    UPDATE aso_apr_obj_approvals
    SET object_id = DECODE (
                      p_object_id,
                      fnd_api.g_miss_num,
                      object_id,
                      p_object_id
                    ),
        object_type = DECODE (
                        p_object_type,
                        fnd_api.g_miss_char,
                        object_type,
                        p_object_type
                      ),
        approval_instance_id = DECODE (
                                 p_approval_instance_id,
                                 fnd_api.g_miss_num,
                                 approval_instance_id,
                                 p_approval_instance_id
                               ),
        approval_status = DECODE (
                            p_approval_status,
                            fnd_api.g_miss_char,
                            approval_status,
                            p_approval_status
                          ),
        application_id = DECODE (
                           p_application_id,
                           fnd_api.g_miss_num,
                           application_id,
                           p_application_id
                         ),
        start_date = aso_utility_pvt.DECODE (
                       p_start_date,
                       fnd_api.g_miss_date,
                       start_date,
                       p_start_date
                     ),
        end_date = aso_utility_pvt.DECODE (
                     p_end_date,
                     fnd_api.g_miss_date,
                     end_date,
                     p_end_date
                   ),
        last_update_date = aso_utility_pvt.DECODE (
                             p_last_update_date,
                             fnd_api.g_miss_date,
                             last_update_date,
                             p_last_update_date
                           ),
        last_updated_by = DECODE (
                            p_last_updated_by,
                            fnd_api.g_miss_num,
                            last_updated_by,
                            p_last_updated_by
                          ),
        last_update_login = DECODE (
                              p_last_update_login,
                              fnd_api.g_miss_num,
                              last_update_login,
                              p_last_update_login
                            ),
        attribute1 = DECODE (
                       p_attribute1,
                       fnd_api.g_miss_char,
                       attribute1,
                       p_attribute1
                     ),
        attribute2 = DECODE (
                       p_attribute2,
                       fnd_api.g_miss_char,
                       attribute2,
                       p_attribute2
                     ),
        attribute3 = DECODE (
                       p_attribute3,
                       fnd_api.g_miss_char,
                       attribute3,
                       p_attribute3
                     ),
        attribute4 = DECODE (
                       p_attribute4,
                       fnd_api.g_miss_char,
                       attribute4,
                       p_attribute4
                     ),
        attribute5 = DECODE (
                       p_attribute5,
                       fnd_api.g_miss_char,
                       attribute5,
                       p_attribute5
                     ),
        attribute6 = DECODE (
                       p_attribute6,
                       fnd_api.g_miss_char,
                       attribute6,
                       p_attribute6
                     ),
        attribute7 = DECODE (
                       p_attribute7,
                       fnd_api.g_miss_char,
                       attribute7,
                       p_attribute7
                     ),
        attribute8 = DECODE (
                       p_attribute8,
                       fnd_api.g_miss_char,
                       attribute8,
                       p_attribute8
                     ),
        attribute9 = DECODE (
                       p_attribute9,
                       fnd_api.g_miss_char,
                       attribute9,
                       p_attribute9
                     ),
        attribute10 = DECODE (
                        p_attribute10,
                        fnd_api.g_miss_char,
                        attribute10,
                        p_attribute10
                      ),
        attribute11 = DECODE (
                        p_attribute11,
                        fnd_api.g_miss_char,
                        attribute11,
                        p_attribute11
                      ),
        attribute12 = DECODE (
                        p_attribute12,
                        fnd_api.g_miss_char,
                        attribute12,
                        p_attribute12
                      ),
        attribute13 = DECODE (
                        p_attribute13,
                        fnd_api.g_miss_char,
                        attribute13,
                        p_attribute13
                      ),
        attribute14 = DECODE (
                        p_attribute14,
                        fnd_api.g_miss_char,
                        attribute14,
                        p_attribute14
                      ),
        attribute15 = DECODE (
                        p_attribute15,
                        fnd_api.g_miss_char,
                        attribute15,
                        p_attribute15
                      ),
        attribute16 = DECODE (
                        p_attribute16,
                        fnd_api.g_miss_char,
                        attribute16,
                        p_attribute16
                      ),
        attribute17 = DECODE (
                        p_attribute17,
                        fnd_api.g_miss_char,
                        attribute17,
                        p_attribute17
                      ),
        attribute18 = DECODE (
                        p_attribute18,
                        fnd_api.g_miss_char,
                        attribute18,
                        p_attribute18
                      ),
        attribute19 = DECODE (
                        p_attribute19,
                        fnd_api.g_miss_char,
                        attribute19,
                        p_attribute19
                      ),
        attribute20 = DECODE (
                        p_attribute20,
                        fnd_api.g_miss_char,
                        attribute20,
                        p_attribute20
                      ),
        CONTEXT = DECODE (
                    p_context,
                    fnd_api.g_miss_char,
                    CONTEXT,
                    p_context
                  ),
        security_group_id = DECODE (
                              p_security_group_id,
                              fnd_api.g_miss_num,
                              security_group_id,
                              p_security_group_id
                            ),
        object_version_number = DECODE (
                                  p_object_version_number,
                                  fnd_api.g_miss_num,
                                  object_version_number,
                                  p_object_version_number
                                ),
        requester_userid = DECODE (
                             p_requester_userid,
                             fnd_api.g_miss_num,
                             requester_userid,
                             p_requester_userid
                           ),
        requester_comments = DECODE (
                               p_requester_comments,
                               fnd_api.g_miss_char,
                               requester_comments,
                               p_requester_comments
                             ),
        requester_group_id = DECODE (
                               p_requester_group_id,
                               fnd_api.g_miss_num,
                               requester_group_id,
                               p_requester_group_id
                             )
    WHERE object_approval_id = p_object_approval_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Header_Update_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END header_update_row;

  PROCEDURE header_delete_row (
    p_object_approval_id                 NUMBER
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Header_Delete_Row procedure  ',
        1,
        'N'
      );
    END IF;

    DELETE FROM aso_apr_obj_approvals
    WHERE object_approval_id = p_object_approval_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Header_Delete_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END header_delete_row;

  PROCEDURE header_lock_row (
    p_object_approval_id                 NUMBER,
    p_object_id                          NUMBER,
    p_object_type                        VARCHAR2,
    p_approval_instance_id               NUMBER,
    p_approval_status                    VARCHAR2,
    p_application_id                     NUMBER,
    p_start_date                         DATE,
    p_end_date                           DATE,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER,
    p_requester_userid                   NUMBER,
    p_requester_comments                 VARCHAR2,
    p_requester_group_id                 NUMBER
  ) IS
    CURSOR c IS
      SELECT object_id, object_type, approval_instance_id, approval_status,
             application_id, start_date, end_date, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login, attribute1,
             attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
             attribute8, attribute9, attribute10, attribute11, attribute12,
             attribute13, attribute14, attribute15, CONTEXT, security_group_id,
             object_version_number, requester_userid, requester_comments,
             requester_group_id
      FROM aso_apr_obj_approvals
      WHERE object_approval_id = p_object_approval_id
      FOR UPDATE OF object_approval_id NOWAIT;

    recinfo                       c%ROWTYPE;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Header_Lock_Row procedure  ',
        1,
        'N'
      );
    END IF;
    OPEN c;
    FETCH c INTO recinfo;

    IF (c%NOTFOUND)
    THEN
      CLOSE c;
      fnd_message.set_name (
        'FND',
        'FORM_RECORD_DELETED'
      );
      app_exception.raise_exception;
    END IF;

    CLOSE c;

    IF (((recinfo.last_update_date = p_last_update_date)
         OR ((recinfo.last_update_date IS NULL)
             AND (p_last_update_date IS NULL)
            )
        )
       )
    THEN
      RETURN;
    ELSE
      fnd_message.set_name (
        'FND',
        'FORM_RECORD_CHANGED'
      );
      app_exception.raise_exception;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Header_Lock_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END header_lock_row;

  PROCEDURE detail_insert_row (
    px_approval_det_id          IN OUT NOCOPY /* file.sql.39 change */     NUMBER,
    p_object_approval_id                 NUMBER,
    p_approver_person_id                 NUMBER,
    p_approver_user_id                   NUMBER,
    p_approver_sequence                  NUMBER,
    p_approver_status                    VARCHAR2,
    p_approver_comments                  VARCHAR2,
    p_date_sent                          DATE,
    p_date_received                      DATE,
    p_creation_date                      DATE,
    p_last_update_date                   DATE,
    p_created_by                         NUMBER,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  ) IS
    CURSOR c2 IS
      SELECT aso_apr_obj_det_s.NEXTVAL
      FROM sys.DUAL;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Detail_Insert_Row procedure  ',
        1,
        'N'
      );
    END IF;

    IF (px_approval_det_id IS NULL)
       OR (px_approval_det_id = fnd_api.g_miss_num)
    THEN
      OPEN c2;
      FETCH c2 INTO px_approval_det_id;
      CLOSE c2;
    END IF;

    INSERT INTO aso_apr_approval_details
     (approval_det_id,
      object_approval_id,
      approver_person_id,
      approver_user_id,
      approver_sequence,
      approver_status,
      approver_comments,
      date_sent,
      date_received,
      creation_date,
      last_update_date,
      created_by,
      last_updated_by,
      last_update_login,
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
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      CONTEXT,
      security_group_id,
      object_version_number)
    VALUES (px_approval_det_id,
            DECODE (
              p_object_approval_id,
              fnd_api.g_miss_num,
              NULL,
              p_object_approval_id
            ),
            DECODE (
              p_approver_person_id,
              fnd_api.g_miss_num,
              NULL,
              p_approver_person_id
            ),
            DECODE (
              p_approver_user_id,
              fnd_api.g_miss_num,
              NULL,
              p_approver_user_id
            ),
            DECODE (
              p_approver_sequence,
              fnd_api.g_miss_num,
              NULL,
              p_approver_sequence
            ),
            DECODE (
              p_approver_status,
              fnd_api.g_miss_char,
              NULL,
              p_approver_status
            ),
            DECODE (
              p_approver_comments,
              fnd_api.g_miss_char,
              NULL,
              p_approver_comments
            ),
            aso_utility_pvt.DECODE (
              p_date_sent,
              fnd_api.g_miss_date,
              NULL,
              p_date_sent
            ),
            aso_utility_pvt.DECODE (
              p_date_received,
              fnd_api.g_miss_date,
              NULL,
              p_date_received
            ),
            aso_utility_pvt.DECODE (
              p_creation_date,
              fnd_api.g_miss_date,
              NULL,
              p_creation_date
            ),
            aso_utility_pvt.DECODE (
              p_last_update_date,
              fnd_api.g_miss_date,
              NULL,
              p_last_update_date
            ),
            DECODE (
              p_created_by,
              fnd_api.g_miss_num,
              NULL,
              p_created_by
            ),
            DECODE (
              p_last_updated_by,
              fnd_api.g_miss_num,
              NULL,
              p_last_updated_by
            ),
            DECODE (
              p_last_update_login,
              fnd_api.g_miss_num,
              NULL,
              p_last_update_login
            ),
            DECODE (
              p_attribute1,
              fnd_api.g_miss_char,
              NULL,
              p_attribute1
            ),
            DECODE (
              p_attribute2,
              fnd_api.g_miss_char,
              NULL,
              p_attribute2
            ),
            DECODE (
              p_attribute3,
              fnd_api.g_miss_char,
              NULL,
              p_attribute3
            ),
            DECODE (
              p_attribute4,
              fnd_api.g_miss_char,
              NULL,
              p_attribute4
            ),
            DECODE (
              p_attribute5,
              fnd_api.g_miss_char,
              NULL,
              p_attribute5
            ),
            DECODE (
              p_attribute6,
              fnd_api.g_miss_char,
              NULL,
              p_attribute6
            ),
            DECODE (
              p_attribute7,
              fnd_api.g_miss_char,
              NULL,
              p_attribute7
            ),
            DECODE (
              p_attribute8,
              fnd_api.g_miss_char,
              NULL,
              p_attribute8
            ),
            DECODE (
              p_attribute9,
              fnd_api.g_miss_char,
              NULL,
              p_attribute9
            ),
            DECODE (
              p_attribute10,
              fnd_api.g_miss_char,
              NULL,
              p_attribute10
            ),
            DECODE (
              p_attribute11,
              fnd_api.g_miss_char,
              NULL,
              p_attribute11
            ),
            DECODE (
              p_attribute12,
              fnd_api.g_miss_char,
              NULL,
              p_attribute12
            ),
            DECODE (
              p_attribute13,
              fnd_api.g_miss_char,
              NULL,
              p_attribute13
            ),
            DECODE (
              p_attribute14,
              fnd_api.g_miss_char,
              NULL,
              p_attribute14
            ),
            DECODE (
              p_attribute15,
              fnd_api.g_miss_char,
              NULL,
              p_attribute15
            ),
             DECODE (
              p_attribute16,
              fnd_api.g_miss_char,
              NULL,
              p_attribute16
            ),
            DECODE (
              p_attribute17,
              fnd_api.g_miss_char,
              NULL,
              p_attribute17
            ),
            DECODE (
              p_attribute18,
              fnd_api.g_miss_char,
              NULL,
              p_attribute18
            ),
            DECODE (
              p_attribute19,
              fnd_api.g_miss_char,
              NULL,
              p_attribute19
            ),
            DECODE (
              p_attribute20,
              fnd_api.g_miss_char,
              NULL,
              p_attribute20
            ),
            DECODE (
              p_context,
              fnd_api.g_miss_char,
              NULL,
              p_context
            ),
            DECODE (
              p_security_group_id,
              fnd_api.g_miss_num,
              NULL,
              p_security_group_id
            ),
            DECODE (
              p_object_version_number,
              fnd_api.g_miss_num,
              NULL,
              p_object_version_number
            ));

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Detail_Insert_Row procedure  ',
        1,
        'N'
      );
    END IF;
  -- EXCEPTION
  -- WHEN OTHERS THEN
  --   aso_debug_pub.add('Exception in  Detail_Insert_Row procedure  ', 1, 'N');
  --   aso_debug_pub.add('errmsg is  '||substr(SQLERRM,1,250), 1, 'N');

  END detail_insert_row;

  PROCEDURE detail_update_row (
    p_approval_det_id                    NUMBER,
    p_object_approval_id                 NUMBER,
    p_approver_person_id                 NUMBER,
    p_approver_user_id                   NUMBER,
    p_approver_sequence                  NUMBER,
    p_approver_status                    VARCHAR2,
    p_approver_comments                  VARCHAR2,
    p_date_sent                          DATE,
    p_date_received                      DATE,
    p_creation_date                      DATE,
    p_last_update_date                   DATE,
    p_created_by                         NUMBER,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin  Detail_Update_Row procedure  ',
        1,
        'N'
      );
    END IF;

    UPDATE aso_apr_approval_details
    SET approval_det_id = DECODE (
                            p_approval_det_id,
                            fnd_api.g_miss_num,
                            approval_det_id,
                            p_approval_det_id
                          ),
        object_approval_id = DECODE (
                               p_object_approval_id,
                               fnd_api.g_miss_num,
                               object_approval_id,
                               p_object_approval_id
                             ),
        approver_person_id = DECODE (
                               p_approver_person_id,
                               fnd_api.g_miss_num,
                               approver_person_id,
                               p_approver_person_id
                             ),
        approver_user_id = DECODE (
                             p_approver_user_id,
                             fnd_api.g_miss_num,
                             approver_user_id,
                             p_approver_user_id
                           ),
        approver_sequence = DECODE (
                              p_approver_sequence,
                              fnd_api.g_miss_num,
                              approver_sequence,
                              p_approver_sequence
                            ),
        approver_status = DECODE (
                            p_approver_status,
                            fnd_api.g_miss_char,
                            approver_status,
                            p_approver_status
                          ),
        approver_comments = DECODE (
                              p_approver_comments,
                              fnd_api.g_miss_char,
                              approver_comments,
                              p_approver_comments
                            ),
        date_sent = aso_utility_pvt.DECODE (
                      p_date_sent,
                      fnd_api.g_miss_date,
                      date_sent,
                      p_date_sent
                    ),
        date_received = aso_utility_pvt.DECODE (
                          p_date_received,
                          fnd_api.g_miss_date,
                          date_received,
                          p_date_received
                        ),
        creation_date = aso_utility_pvt.DECODE (
                          p_creation_date,
                          fnd_api.g_miss_date,
                          creation_date,
                          p_creation_date
                        ),
        last_update_date = aso_utility_pvt.DECODE (
                             p_last_update_date,
                             fnd_api.g_miss_date,
                             last_update_date,
                             p_last_update_date
                           ),
        created_by = DECODE (
                       p_created_by,
                       fnd_api.g_miss_num,
                       created_by,
                       p_created_by
                     ),
        last_updated_by = DECODE (
                            p_last_updated_by,
                            fnd_api.g_miss_num,
                            last_updated_by,
                            p_last_updated_by
                          ),
        last_update_login = DECODE (
                              p_last_update_login,
                              fnd_api.g_miss_num,
                              last_update_login,
                              p_last_update_login
                            ),
        attribute1 = DECODE (
                       p_attribute1,
                       fnd_api.g_miss_char,
                       attribute1,
                       p_attribute1
                     ),
        attribute2 = DECODE (
                       p_attribute2,
                       fnd_api.g_miss_char,
                       attribute2,
                       p_attribute2
                     ),
        attribute3 = DECODE (
                       p_attribute3,
                       fnd_api.g_miss_char,
                       attribute3,
                       p_attribute3
                     ),
        attribute4 = DECODE (
                       p_attribute4,
                       fnd_api.g_miss_char,
                       attribute4,
                       p_attribute4
                     ),
        attribute5 = DECODE (
                       p_attribute5,
                       fnd_api.g_miss_char,
                       attribute5,
                       p_attribute5
                     ),
        attribute6 = DECODE (
                       p_attribute6,
                       fnd_api.g_miss_char,
                       attribute6,
                       p_attribute6
                     ),
        attribute7 = DECODE (
                       p_attribute7,
                       fnd_api.g_miss_char,
                       attribute7,
                       p_attribute7
                     ),
        attribute8 = DECODE (
                       p_attribute8,
                       fnd_api.g_miss_char,
                       attribute8,
                       p_attribute8
                     ),
        attribute9 = DECODE (
                       p_attribute9,
                       fnd_api.g_miss_char,
                       attribute9,
                       p_attribute9
                     ),
        attribute10 = DECODE (
                        p_attribute10,
                        fnd_api.g_miss_char,
                        attribute10,
                        p_attribute10
                      ),
        attribute11 = DECODE (
                        p_attribute11,
                        fnd_api.g_miss_char,
                        attribute11,
                        p_attribute11
                      ),
        attribute12 = DECODE (
                        p_attribute12,
                        fnd_api.g_miss_char,
                        attribute12,
                        p_attribute12
                      ),
        attribute13 = DECODE (
                        p_attribute13,
                        fnd_api.g_miss_char,
                        attribute13,
                        p_attribute13
                      ),
        attribute14 = DECODE (
                        p_attribute14,
                        fnd_api.g_miss_char,
                        attribute14,
                        p_attribute14
                      ),
        attribute15 = DECODE (
                        p_attribute15,
                        fnd_api.g_miss_char,
                        attribute15,
                        p_attribute15
                      ),
         attribute16 = DECODE (
                        p_attribute16,
                        fnd_api.g_miss_char,
                        attribute16,
                        p_attribute16
                      ),
        attribute17 = DECODE (
                        p_attribute17,
                        fnd_api.g_miss_char,
                        attribute17,
                        p_attribute17
                      ),
        attribute18 = DECODE (
                        p_attribute18,
                        fnd_api.g_miss_char,
                        attribute18,
                        p_attribute18
                      ),
        attribute19 = DECODE (
                        p_attribute19,
                        fnd_api.g_miss_char,
                        attribute19,
                        p_attribute19
                      ),
        attribute20 = DECODE (
                        p_attribute20,
                        fnd_api.g_miss_char,
                        attribute20,
                        p_attribute20
                      ),
        CONTEXT = DECODE (
                    p_context,
                    fnd_api.g_miss_char,
                    CONTEXT,
                    p_context
                  ),
        security_group_id = DECODE (
                              p_security_group_id,
                              fnd_api.g_miss_num,
                              security_group_id,
                              p_security_group_id
                            ),
        object_version_number = DECODE (
                                  p_object_version_number,
                                  fnd_api.g_miss_num,
                                  object_version_number,
                                  p_object_version_number
                                )
    WHERE approval_det_id = p_approval_det_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  Detail_Update_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END detail_update_row;

  PROCEDURE detail_lock_row (
    p_approval_det_id                    NUMBER,
    p_object_approval_id                 NUMBER,
    p_approver_person_id                 NUMBER,
    p_approver_user_id                   NUMBER,
    p_approver_sequence                  NUMBER,
    p_approver_status                    VARCHAR2,
    p_approver_comments                  VARCHAR2,
    p_date_sent                          DATE,
    p_date_received                      DATE,
    p_creation_date                      DATE,
    p_last_update_date                   DATE,
    p_created_by                         NUMBER,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  ) IS
    CURSOR c IS
      SELECT approval_det_id, object_approval_id, approver_person_id,
             approver_user_id, approver_sequence, approver_status,
             approver_comments, date_sent, date_received, creation_date,
             last_update_date, created_by, last_updated_by, last_update_login,
             attribute1, attribute2, attribute3, attribute4, attribute5, attribute6,
             attribute7, attribute8, attribute9, attribute10, attribute11,
             attribute12, attribute13, attribute14, attribute15, CONTEXT,
             security_group_id, object_version_number
      FROM aso_apr_approval_details
      WHERE approval_det_id = p_approval_det_id
      FOR UPDATE OF approval_det_id NOWAIT;

    recinfo                       c%ROWTYPE;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin  Detail_Lock_Row procedure  ',
        1,
        'N'
      );
    END IF;
    OPEN c;
    FETCH c INTO recinfo;

    IF (c%NOTFOUND)
    THEN
      CLOSE c;
      fnd_message.set_name (
        'FND',
        'FORM_RECORD_DELETED'
      );
      app_exception.raise_exception;
    END IF;

    CLOSE c;

    IF (((recinfo.last_update_date = p_last_update_date)
         OR ((recinfo.last_update_date IS NULL)
             AND (p_last_update_date IS NULL)
            )
        )
       )
    THEN
      RETURN;
    ELSE
      fnd_message.set_name (
        'FND',
        'FORM_RECORD_CHANGED'
      );
      app_exception.raise_exception;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  Detail_Lock_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END detail_lock_row;

  PROCEDURE detail_delete_row (
    p_approval_det_id                    NUMBER
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Detail_Delete_Row procedure  ',
        1,
        'N'
      );
    END IF;

    DELETE FROM aso_apr_approval_details
    WHERE approval_det_id = p_approval_det_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  Detail_Delete_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END detail_delete_row;
  -- Procedures for the Rule Table

  PROCEDURE rule_insert_row (
    px_rule_id                  IN OUT NOCOPY /* file.sql.39 change */     NUMBER,
    p_oam_rule_id                        NUMBER,
    p_rule_action_id                     NUMBER,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_object_approval_id                 NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  ) IS
    CURSOR c2 IS
      SELECT aso_apr_rule_s.NEXTVAL
      FROM sys.DUAL;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin   Rule_Insert_Row procedure  ',
        1,
        'N'
      );
    END IF;
    --If (px_RULE_ID IS NULL) OR (px_RULE_ID = FND_API.G_MISS_NUM) then
    OPEN c2;
    FETCH c2 INTO px_rule_id;
    CLOSE c2;
    --End If;
    INSERT INTO aso_apr_rules
     (rule_id,
      oam_rule_id,
      rule_action_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      object_approval_id,
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
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      CONTEXT,
      security_group_id,
      object_version_number)
    VALUES (px_rule_id,
            DECODE (
              p_oam_rule_id,
              fnd_api.g_miss_num,
              NULL,
              p_oam_rule_id
            ),
            DECODE (
              p_rule_action_id,
              fnd_api.g_miss_num,
              NULL,
              p_rule_action_id
            ),
            aso_utility_pvt.DECODE (
              p_creation_date,
              fnd_api.g_miss_date,
              NULL,
              p_creation_date
            ),
            DECODE (
              p_created_by,
              fnd_api.g_miss_num,
              NULL,
              p_created_by
            ),
            aso_utility_pvt.DECODE (
              p_last_update_date,
              fnd_api.g_miss_date,
              NULL,
              p_last_update_date
            ),
            DECODE (
              p_last_updated_by,
              fnd_api.g_miss_num,
              NULL,
              p_last_updated_by
            ),
            DECODE (
              p_last_update_login,
              fnd_api.g_miss_num,
              NULL,
              p_last_update_login
            ),
            DECODE (
              p_object_approval_id,
              fnd_api.g_miss_num,
              NULL,
              p_object_approval_id
            ),
            DECODE (
              p_attribute1,
              fnd_api.g_miss_char,
              NULL,
              p_attribute1
            ),
            DECODE (
              p_attribute2,
              fnd_api.g_miss_char,
              NULL,
              p_attribute2
            ),
            DECODE (
              p_attribute3,
              fnd_api.g_miss_char,
              NULL,
              p_attribute3
            ),
            DECODE (
              p_attribute4,
              fnd_api.g_miss_char,
              NULL,
              p_attribute4
            ),
            DECODE (
              p_attribute5,
              fnd_api.g_miss_char,
              NULL,
              p_attribute5
            ),
            DECODE (
              p_attribute6,
              fnd_api.g_miss_char,
              NULL,
              p_attribute6
            ),
            DECODE (
              p_attribute7,
              fnd_api.g_miss_char,
              NULL,
              p_attribute7
            ),
            DECODE (
              p_attribute8,
              fnd_api.g_miss_char,
              NULL,
              p_attribute8
            ),
            DECODE (
              p_attribute9,
              fnd_api.g_miss_char,
              NULL,
              p_attribute9
            ),
            DECODE (
              p_attribute10,
              fnd_api.g_miss_char,
              NULL,
              p_attribute10
            ),
            DECODE (
              p_attribute11,
              fnd_api.g_miss_char,
              NULL,
              p_attribute11
            ),
            DECODE (
              p_attribute12,
              fnd_api.g_miss_char,
              NULL,
              p_attribute12
            ),
            DECODE (
              p_attribute13,
              fnd_api.g_miss_char,
              NULL,
              p_attribute13
            ),
            DECODE (
              p_attribute14,
              fnd_api.g_miss_char,
              NULL,
              p_attribute14
            ),
            DECODE (
              p_attribute15,
              fnd_api.g_miss_char,
              NULL,
              p_attribute15
            ),
             DECODE (
              p_attribute16,
              fnd_api.g_miss_char,
              NULL,
              p_attribute16
            ),
            DECODE (
              p_attribute17,
              fnd_api.g_miss_char,
              NULL,
              p_attribute17
            ),
            DECODE (
              p_attribute18,
              fnd_api.g_miss_char,
              NULL,
              p_attribute18
            ),
            DECODE (
              p_attribute19,
              fnd_api.g_miss_char,
              NULL,
              p_attribute19
            ),
            DECODE (
              p_attribute20,
              fnd_api.g_miss_char,
              NULL,
              p_attribute20
            ),
            DECODE (
              p_context,
              fnd_api.g_miss_char,
              NULL,
              p_context
            ),
            DECODE (
              p_security_group_id,
              fnd_api.g_miss_num,
              NULL,
              p_security_group_id
            ),
            DECODE (
              p_object_version_number,
              fnd_api.g_miss_num,
              NULL,
              p_object_version_number
            ));

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  Rule_Insert_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END rule_insert_row;

  PROCEDURE rule_update_row (
    p_rule_id                            NUMBER,
    p_oam_rule_id                        NUMBER,
    p_rule_action_id                     NUMBER,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_object_approval_id                 NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin   Rule_Update_Row procedure  ',
        1,
        'N'
      );
    END IF;

    UPDATE aso_apr_rules
    SET rule_id = p_rule_id,
        oam_rule_id = DECODE (
                        p_oam_rule_id,
                        fnd_api.g_miss_num,
                        rule_id,
                        p_oam_rule_id
                      ),
        rule_action_id = DECODE (
                           p_rule_action_id,
                           fnd_api.g_miss_num,
                           rule_action_id,
                           p_rule_action_id
                         ),
        creation_date = aso_utility_pvt.DECODE (
                          p_creation_date,
                          fnd_api.g_miss_date,
                          creation_date,
                          p_creation_date
                        ),
        created_by = DECODE (
                       p_created_by,
                       fnd_api.g_miss_num,
                       created_by,
                       p_created_by
                     ),
        last_update_date = aso_utility_pvt.DECODE (
                             p_last_update_date,
                             fnd_api.g_miss_date,
                             last_update_date,
                             p_last_update_date
                           ),
        last_updated_by = DECODE (
                            p_last_updated_by,
                            fnd_api.g_miss_num,
                            NULL,
                            p_last_updated_by
                          ),
        last_update_login = DECODE (
                              p_last_update_login,
                              fnd_api.g_miss_num,
                              last_update_login,
                              p_last_update_login
                            ),
        object_approval_id = DECODE (
                               p_object_approval_id,
                               fnd_api.g_miss_num,
                               object_approval_id,
                               p_object_approval_id
                             ),
        attribute1 = DECODE (
                       p_attribute1,
                       fnd_api.g_miss_char,
                       attribute1,
                       p_attribute1
                     ),
        attribute2 = DECODE (
                       p_attribute2,
                       fnd_api.g_miss_char,
                       attribute2,
                       p_attribute2
                     ),
        attribute3 = DECODE (
                       p_attribute3,
                       fnd_api.g_miss_char,
                       attribute3,
                       p_attribute3
                     ),
        attribute4 = DECODE (
                       p_attribute4,
                       fnd_api.g_miss_char,
                       attribute4,
                       p_attribute4
                     ),
        attribute5 = DECODE (
                       p_attribute5,
                       fnd_api.g_miss_char,
                       attribute5,
                       p_attribute5
                     ),
        attribute6 = DECODE (
                       p_attribute6,
                       fnd_api.g_miss_char,
                       attribute6,
                       p_attribute6
                     ),
        attribute7 = DECODE (
                       p_attribute7,
                       fnd_api.g_miss_char,
                       attribute7,
                       p_attribute7
                     ),
        attribute8 = DECODE (
                       p_attribute8,
                       fnd_api.g_miss_char,
                       attribute8,
                       p_attribute8
                     ),
        attribute9 = DECODE (
                       p_attribute9,
                       fnd_api.g_miss_char,
                       attribute9,
                       p_attribute9
                     ),
        attribute10 = DECODE (
                        p_attribute10,
                        fnd_api.g_miss_char,
                        attribute10,
                        p_attribute10
                      ),
        attribute11 = DECODE (
                        p_attribute11,
                        fnd_api.g_miss_char,
                        attribute11,
                        p_attribute11
                      ),
        attribute12 = DECODE (
                        p_attribute12,
                        fnd_api.g_miss_char,
                        attribute12,
                        p_attribute12
                      ),
        attribute13 = DECODE (
                        p_attribute13,
                        fnd_api.g_miss_char,
                        attribute13,
                        p_attribute13
                      ),
        attribute14 = DECODE (
                        p_attribute14,
                        fnd_api.g_miss_char,
                        attribute14,
                        p_attribute14
                      ),
        attribute15 = DECODE (
                        p_attribute15,
                        fnd_api.g_miss_char,
                        attribute15,
                        p_attribute15
                      ),
        attribute16 = DECODE (
                        p_attribute16,
                        fnd_api.g_miss_char,
                        attribute16,
                        p_attribute16
                      ),
        attribute17 = DECODE (
                        p_attribute17,
                        fnd_api.g_miss_char,
                        attribute17,
                        p_attribute17
                      ),
        attribute18 = DECODE (
                        p_attribute18,
                        fnd_api.g_miss_char,
                        attribute18,
                        p_attribute18
                      ),
        attribute19 = DECODE (
                        p_attribute19,
                        fnd_api.g_miss_char,
                        attribute19,
                        p_attribute19
                      ),
        attribute20 = DECODE (
                        p_attribute20,
                        fnd_api.g_miss_char,
                        attribute20,
                        p_attribute20
                      ),
        CONTEXT = DECODE (
                    p_context,
                    fnd_api.g_miss_char,
                    CONTEXT,
                    p_context
                  ),
        security_group_id = DECODE (
                              p_security_group_id,
                              fnd_api.g_miss_num,
                              security_group_id,
                              p_security_group_id
                            ),
        object_version_number = DECODE (
                                  p_object_version_number,
                                  fnd_api.g_miss_num,
                                  object_version_number,
                                  p_object_version_number
                                )
    WHERE rule_id = p_rule_id;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Rule_Update_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END rule_update_row;

  PROCEDURE rule_lock_row (
    p_rule_id                            NUMBER,
    p_oam_rule_id                        NUMBER,
    p_rule_action_id                     NUMBER,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_object_approval_id                 NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  ) IS
    CURSOR c IS
      SELECT rule_id, oam_rule_id, rule_action_id, creation_date, created_by,
             last_update_date, last_updated_by, last_update_login,
             object_approval_id, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9,
             attribute10, attribute11, attribute12, attribute13, attribute14,
             attribute15, CONTEXT, security_group_id, object_version_number
      FROM aso_apr_rules
      WHERE rule_id = p_rule_id
      FOR UPDATE OF rule_id NOWAIT;

    recinfo                       c%ROWTYPE;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin  Rule_Lock_Row procedure  ',
        1,
        'N'
      );
    END IF;
    OPEN c;
    FETCH c INTO recinfo;

    IF (c%NOTFOUND)
    THEN
      CLOSE c;
      fnd_message.set_name (
        'FND',
        'FORM_RECORD_DELETED'
      );
      app_exception.raise_exception;
    END IF;

    CLOSE c;

    IF (((recinfo.last_update_date = p_last_update_date)
         OR ((recinfo.last_update_date IS NULL)
             AND (p_last_update_date IS NULL)
            )
        )
       )
    THEN
      RETURN;
    ELSE
      fnd_message.set_name (
        'FND',
        'FORM_RECORD_CHANGED'
      );
      app_exception.raise_exception;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  Rule_Lock_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END rule_lock_row;

  PROCEDURE rule_delete_row (
    p_rule_id                            NUMBER
  ) IS
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Rule_Delete_Row procedure  ',
        1,
        'N'
      );
    END IF;

    DELETE FROM aso_apr_rules
    WHERE rule_id = p_rule_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End Rule_Delete_Row procedure  ',
        1,
        'N'
      );
    END IF;
  END rule_delete_row;
END aso_apr_approvals_pkg;

/
