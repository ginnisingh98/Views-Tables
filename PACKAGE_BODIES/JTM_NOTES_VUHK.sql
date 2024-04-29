--------------------------------------------------------
--  DDL for Package Body JTM_NOTES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_NOTES_VUHK" AS
/* $Header: jtmhkntb.pls 120.1 2005/08/24 02:13:23 saradhak noship $ */

Cursor Get_hook_info(p_processing_type in varchar2, p_api_name in varchar2) is
     Select HOOK_PACKAGE, HOOK_API , EXECUTE_FLAG, PRODUCT_CODE
	 from JTF_HOOKS_DATA
	 Where package_name = 'JTM_NOTES_PUB' and
	 upper(api_name) = upper(p_api_name) and
	 processing_type = p_processing_type and
         execute_flag = 'Y' and
	 hook_type = 'V';

/* Verticals Procedure for pre processing in case of create note */

PROCEDURE create_note_pre
( p_parent_note_id          IN     NUMBER
, p_api_version             IN     NUMBER
, p_init_msg_list           IN     VARCHAR2
, p_commit                  IN     VARCHAR2
, p_validation_level        IN     NUMBER
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_org_id                  IN     NUMBER
, p_source_object_id        IN     NUMBER
, p_source_object_code      IN     VARCHAR2
, p_notes                   IN     VARCHAR2
, p_notes_detail            IN     VARCHAR2
, p_note_status             IN     VARCHAR2
, p_entered_by              IN     NUMBER
, p_entered_date            IN     DATE
, x_jtf_note_id                OUT NOCOPY NUMBER
, p_last_update_date        IN     DATE
, p_last_updated_by         IN     NUMBER
, p_creation_date           IN     DATE
, p_created_by              IN     NUMBER
, p_last_update_login       IN     NUMBER
, p_attribute1              IN     VARCHAR2
, p_attribute2              IN     VARCHAR2
, p_attribute3              IN     VARCHAR2
, p_attribute4              IN     VARCHAR2
, p_attribute5              IN     VARCHAR2
, p_attribute6              IN     VARCHAR2
, p_attribute7              IN     VARCHAR2
, p_attribute8              IN     VARCHAR2
, p_attribute9              IN     VARCHAR2
, p_attribute10             IN     VARCHAR2
, p_attribute11             IN     VARCHAR2
, p_attribute12             IN     VARCHAR2
, p_attribute13             IN     VARCHAR2
, p_attribute14             IN     VARCHAR2
, p_attribute15             IN     VARCHAR2
, p_context                 IN     VARCHAR2
, p_note_type               IN     VARCHAR2
, p_jtf_note_contexts_tab   IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status              OUT NOCOPY VARCHAR2
) is
begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
end create_note_pre;


/* Verticals Procedure for post processing in case of create note */

PROCEDURE create_note_post
( p_parent_note_id          IN     NUMBER
, p_api_version             IN     NUMBER
, p_init_msg_list           IN     VARCHAR2
, p_commit                  IN     VARCHAR2
, p_validation_level        IN     NUMBER
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_org_id                  IN     NUMBER
, p_source_object_id        IN     NUMBER
, p_source_object_code      IN     VARCHAR2
, p_notes                   IN     VARCHAR2
, p_notes_detail            IN     VARCHAR2
, p_note_status             IN     VARCHAR2
, p_entered_by              IN     NUMBER
, p_entered_date            IN     DATE
, x_jtf_note_id                OUT NOCOPY NUMBER
, p_last_update_date        IN     DATE
, p_last_updated_by         IN     NUMBER
, p_creation_date           IN     DATE
, p_created_by              IN     NUMBER
, p_last_update_login       IN     NUMBER
, p_attribute1              IN     VARCHAR2
, p_attribute2              IN     VARCHAR2
, p_attribute3              IN     VARCHAR2
, p_attribute4              IN     VARCHAR2
, p_attribute5              IN     VARCHAR2
, p_attribute6              IN     VARCHAR2
, p_attribute7              IN     VARCHAR2
, p_attribute8              IN     VARCHAR2
, p_attribute9              IN     VARCHAR2
, p_attribute10             IN     VARCHAR2
, p_attribute11             IN     VARCHAR2
, p_attribute12             IN     VARCHAR2
, p_attribute13             IN     VARCHAR2
, p_attribute14             IN     VARCHAR2
, p_attribute15             IN     VARCHAR2
, p_context                 IN     VARCHAR2
, p_note_type               IN     VARCHAR2
--, p_jtf_note_contexts_tab   IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status              OUT NOCOPY VARCHAR2
, p_jtf_note_id             IN     NUMBER
) is
  l_enable_flag varchar2(20);
  l_cursorid   INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_execute_status INTEGER;

begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'CREATE_NOTE') LOOP

      /* check execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', p_init_msg_list);
         DBMS_SQL.bind_variable (l_cursorid, ':3', p_commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', x_msg_count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', x_msg_data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', x_return_status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_jtf_note_id);
/*
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8' ||
            ' ,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,' ||
            ' :21,:22,:23,:24,:25,:26,:27,:28,:29,:30,' ||
            ' :31,:32,:33,:34,:35,:36,:37,:38,:40,:41' ||
            '); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_parent_note_id);
         DBMS_SQL.bind_variable (l_cursorid, ':2', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':3', p_init_msg_list);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_commit);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':6', x_msg_count);
         DBMS_SQL.bind_variable (l_cursorid, ':7', x_msg_data);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_jtf_note_id);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_org_id);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_source_object_id);
         DBMS_SQL.bind_variable (l_cursorid, ':10', p_source_object_code);
         DBMS_SQL.bind_variable (l_cursorid, ':11', p_notes);
         DBMS_SQL.bind_variable (l_cursorid, ':12', p_notes_detail);
         DBMS_SQL.bind_variable (l_cursorid, ':13', p_note_status);
         DBMS_SQL.bind_variable (l_cursorid, ':14', p_entered_by);
         DBMS_SQL.bind_variable (l_cursorid, ':15', p_entered_date);
         DBMS_SQL.bind_variable (l_cursorid, ':16', x_jtf_note_id);
         DBMS_SQL.bind_variable (l_cursorid, ':17', p_last_update_date);
         DBMS_SQL.bind_variable (l_cursorid, ':18', p_last_updated_by);
         DBMS_SQL.bind_variable (l_cursorid, ':19', p_creation_date);
         DBMS_SQL.bind_variable (l_cursorid, ':20', p_created_by);
         DBMS_SQL.bind_variable (l_cursorid, ':21', p_last_update_login);
         DBMS_SQL.bind_variable (l_cursorid, ':22', p_attribute1);
         DBMS_SQL.bind_variable (l_cursorid, ':23', p_attribute2);
         DBMS_SQL.bind_variable (l_cursorid, ':24', p_attribute3);
         DBMS_SQL.bind_variable (l_cursorid, ':25', p_attribute4);
         DBMS_SQL.bind_variable (l_cursorid, ':26', p_attribute5);
         DBMS_SQL.bind_variable (l_cursorid, ':27', p_attribute6);
         DBMS_SQL.bind_variable (l_cursorid, ':28', p_attribute7);
         DBMS_SQL.bind_variable (l_cursorid, ':29', p_attribute8);
         DBMS_SQL.bind_variable (l_cursorid, ':30', p_attribute9);
         DBMS_SQL.bind_variable (l_cursorid, ':31', p_attribute10);
         DBMS_SQL.bind_variable (l_cursorid, ':32', p_attribute11);
         DBMS_SQL.bind_variable (l_cursorid, ':33', p_attribute12);
         DBMS_SQL.bind_variable (l_cursorid, ':34', p_attribute13);
         DBMS_SQL.bind_variable (l_cursorid, ':35', p_attribute14);
         DBMS_SQL.bind_variable (l_cursorid, ':36', p_attribute15);
         DBMS_SQL.bind_variable (l_cursorid, ':37', p_context);
         DBMS_SQL.bind_variable (l_cursorid, ':38', p_note_type);
         --DBMS_SQL.BIND_VARIABLE_RAW (l_cursorid, ':39', p_jtf_note_contexts_tab);
         DBMS_SQL.bind_variable (l_cursorid, ':40', x_return_status);
         DBMS_SQL.bind_variable (l_cursorid, ':41', p_jtf_note_id);
*/
         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);

      end if;

   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end create_note_post;


/* Verticals Procedure for pre processing in case of update note */

PROCEDURE update_note_pre
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN     NUMBER
, p_entered_by            IN     NUMBER
, p_last_updated_by       IN     NUMBER
, p_last_update_date      IN     DATE
, p_last_update_login     IN     NUMBER
, p_notes                 IN     VARCHAR2
, p_notes_detail          IN     VARCHAR2
, p_append_flag           IN     VARCHAR2
, p_note_status           IN     VARCHAR2
, p_note_type             IN     VARCHAR2
--, p_jtf_note_contexts_tab IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
) IS
  l_enable_flag varchar2(20);
  l_cursorid   INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_execute_status INTEGER;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'UPDATE_NOTE') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', p_init_msg_list);
         DBMS_SQL.bind_variable (l_cursorid, ':3', p_commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', x_msg_count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', x_msg_data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', x_return_status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_jtf_note_id);

/*
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,' ||
            ' :11,:12,:13,:14,:15,:16,:17); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', p_init_msg_list);
         DBMS_SQL.bind_variable (l_cursorid, ':3', p_commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', x_msg_count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', x_msg_data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_jtf_note_id);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_entered_by);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_last_updated_by);
         DBMS_SQL.bind_variable (l_cursorid, ':10', p_last_update_date);
         DBMS_SQL.bind_variable (l_cursorid, ':11', p_last_update_login);
         DBMS_SQL.bind_variable (l_cursorid, ':12', p_notes);
         DBMS_SQL.bind_variable (l_cursorid, ':13', p_notes_detail);
         DBMS_SQL.bind_variable (l_cursorid, ':14', p_append_flag);
         DBMS_SQL.bind_variable (l_cursorid, ':15', p_note_status);
         DBMS_SQL.bind_variable (l_cursorid, ':16', p_note_type);
         DBMS_SQL.bind_variable (l_cursorid, ':17', x_return_status);
*/
         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;

   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end update_note_pre;


/* Vertical Procedure for post processing in case of update note */

PROCEDURE update_note_post
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN     NUMBER
, p_entered_by            IN     NUMBER
, p_last_updated_by       IN     NUMBER
, p_last_update_date      IN     DATE
, p_last_update_login     IN     NUMBER
, p_notes                 IN     VARCHAR2
, p_notes_detail          IN     VARCHAR2
, p_append_flag           IN     VARCHAR2
, p_note_status           IN     VARCHAR2
, p_note_type             IN     VARCHAR2
--, p_jtf_note_contexts_tab IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
) IS

  l_enable_flag varchar2(20);
  l_cursorid   INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_execute_status INTEGER;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'UPDATE_NOTE') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', p_init_msg_list);
         DBMS_SQL.bind_variable (l_cursorid, ':3', p_commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', x_msg_count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', x_msg_data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', x_return_status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_jtf_note_id);

/*
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,' ||
            ' :11,:12,:13,:14,:15,:16,:17); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', p_init_msg_list);
         DBMS_SQL.bind_variable (l_cursorid, ':3', p_commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', x_msg_count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', x_msg_data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_jtf_note_id);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_entered_by);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_last_updated_by);
         DBMS_SQL.bind_variable (l_cursorid, ':10', p_last_update_date);
         DBMS_SQL.bind_variable (l_cursorid, ':11', p_last_update_login);
         DBMS_SQL.bind_variable (l_cursorid, ':12', p_notes);
         DBMS_SQL.bind_variable (l_cursorid, ':13', p_notes_detail);
         DBMS_SQL.bind_variable (l_cursorid, ':14', p_append_flag);
         DBMS_SQL.bind_variable (l_cursorid, ':15', p_note_status);
         DBMS_SQL.bind_variable (l_cursorid, ':16', p_note_type);
         DBMS_SQL.bind_variable (l_cursorid, ':17', x_return_status);
*/
         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;

   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END;

FUNCTION Ok_to_generate_msg
( p_parent_note_id        IN     NUMBER
, p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_org_id                IN     NUMBER
, p_source_object_id      IN     NUMBER
, p_source_object_code    IN     VARCHAR2
, p_notes                 IN     VARCHAR2
, p_notes_detail          IN     VARCHAR2
, p_note_status           IN     VARCHAR2
, p_entered_by            IN     NUMBER
, p_entered_date          IN     DATE
, x_jtf_note_id              OUT NOCOPY NUMBER
, p_last_update_date      IN     DATE
, p_last_updated_by       IN     NUMBER
, p_creation_date         IN     DATE
, p_created_by            IN     NUMBER
, p_last_update_login     IN     NUMBER
, p_attribute1            IN     VARCHAR2
, p_attribute2            IN     VARCHAR2
, p_attribute3            IN     VARCHAR2
, p_attribute4            IN     VARCHAR2
, p_attribute5            IN     VARCHAR2
, p_attribute6            IN     VARCHAR2
, p_attribute7            IN     VARCHAR2
, p_attribute8            IN     VARCHAR2
, p_attribute9            IN     VARCHAR2
, p_attribute10           IN     VARCHAR2
, p_attribute11           IN     VARCHAR2
, p_attribute12           IN     VARCHAR2
, p_attribute13           IN     VARCHAR2
, p_attribute14           IN     VARCHAR2
, p_attribute15           IN     VARCHAR2
, p_context               IN     VARCHAR2
, p_note_type             IN     VARCHAR2
, p_jtf_note_contexts_tab IN     jtf_notes_pub.jtf_note_contexts_tbl_type
)RETURN BOOLEAN
IS
BEGIN
 RETURN TRUE;
END;

END JTM_notes_vuhk;

/
