--------------------------------------------------------
--  DDL for Package Body IEX_NOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_NOTES_PVT" AS
/* $Header: iexvntsb.pls 120.4 2006/01/06 18:07:26 jypark ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'IEX_NOTES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) :='iexvntsb.pls';
G_APPL_ID NUMBER;
G_LOGIN_ID NUMBER;
G_PROGRAM_ID NUMBER;
--G_USER_ID NUMBER;
G_REQUEST_ID NUMBER;

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER;

PROCEDURE Create_Note(
  p_api_version      IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2,
  p_commit      IN  VARCHAR2,
  p_validation_level    IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_source_object_id    IN  NUMBER,
  p_source_object_code    IN  VARCHAR2,
  p_note_type      IN  VARCHAR2,
  p_notes        IN  VARCHAR2,
  p_contexts_tbl      IN  CONTEXTS_TBL_TYPE,
  x_note_id      OUT NOCOPY NUMBER)
AS
  l_api_name      CONSTANT VARCHAR2(30) := 'Create_Note';
  l_api_version      CONSTANT NUMBER := 1.0;
  l_return_status     VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data       VARCHAR2(32767);
  l_source_object_id    NUMBER;
    l_jtf_note_contexts_table    jtf_notes_pub.jtf_note_contexts_tbl_type;
    i        number;
    p_note_id      number;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT  Create_Note_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- START OF BODY OF API
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: Begin');
  END IF;

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: G_USER_ID = ' || FND_GLOBAL.USER_ID);
  END IF;

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: Going thru context table');
  END IF;
  FOR i IN 1..p_contexts_tbl.COUNT LOOP
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: loop = ' || i);
    END IF;
         l_jtf_note_contexts_table(i).note_context_type := p_contexts_tbl(i).CONTEXT_TYPE;
         l_jtf_note_contexts_table(i).note_context_type_id := p_contexts_tbl(i).CONTEXT_ID;
         l_jtf_note_contexts_table(i).last_update_date  := sysdate;
         l_jtf_note_contexts_table(i).creation_date     := sysdate;
         l_jtf_note_contexts_table(i).last_updated_by   := FND_GLOBAL.USER_ID;
         l_jtf_note_contexts_table(i).created_by        := FND_GLOBAL.USER_ID;
         l_jtf_note_contexts_table(i).last_update_login := FND_GLOBAL.USER_ID;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: ' || l_jtf_note_contexts_table(i).note_context_type);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: ' || l_jtf_note_contexts_table(i).note_context_type_id);
    END IF;
  END LOOP;

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: Before call to jtf_notes_pub.create_note');
  END IF;
      jtf_notes_pub.create_note(
          P_Api_Version                => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => P_Commit,
          p_jtf_note_id                => FND_API.g_MISS_NUM,
          p_validation_level           => p_validation_level,
          p_source_object_id           => p_source_object_id,
          p_source_object_code         => p_source_object_code,
          p_notes                      => p_notes,
          p_entered_by                 => FND_GLOBAL.USER_ID,
          p_entered_date               => sysdate,
          p_last_update_date           => sysdate,
          p_last_updated_by            => FND_GLOBAL.USER_ID,
          p_creation_date              => sysdate,
          p_created_by                 => FND_GLOBAL.USER_ID,
          p_last_update_login          => FND_GLOBAL.USER_ID,
          x_jtf_note_id         => x_note_id,
          X_Return_Status              => l_Return_Status,
          X_Msg_Count                  => l_Msg_Count,
          X_Msg_Data                   => l_Msg_Data,
          p_jtf_note_contexts_tab      => l_jtf_note_contexts_table,
          p_note_type         => p_note_type);

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: After call to jtf_notes_pub.create_note');
  END IF;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: l_Return_Status: ' || l_Return_Status);
  END IF;

  -- check for errors
  IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CREATE_NOTE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

      -- END OF BODY OF API
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.LogMessage(G_PKG_NAME || '.Create_Note: End');
  END IF;

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

  x_return_status := l_return_status;

      -- Standard call to get message count and if count is 1, get message info
      FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_msg_count,
                   p_data => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Note_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Note_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Create_Note_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Create_Note;

-- create by jypark for notes form's getting notes summary functionality
PROCEDURE Get_Notes_Summary(
        p_api_version                   IN  NUMBER,
        p_init_msg_list                 IN  VARCHAR2,
        p_commit                        IN  VARCHAR2,
        p_validation_level              IN  NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        p_user_id                       IN  NUMBER,
        p_object_code                   IN  VARCHAR2,
        p_object_id                     IN  VARCHAR2,
        p_summary_order                 IN  VARCHAR2,
        p_new_line_chr                  IN  VARCHAR2,
        x_notes_summary_tbl             OUT NOCOPY NOTES_SUMMARY_TBL_TYPE) IS

  l_notes       VARCHAR2(32767);
  l_created_by_name    VARCHAR2(360);
  l_entered_date    DATE;
  l_note_type_meaning  VARCHAR2(80);
  l_note_status_meaning  VARCHAR2(80);

  l_curr_rec_size    NUMBER;
  l_note_summary_size  NUMBER;
  l_curr_rec      VARCHAR2(3000);
  l_note_summary    VARCHAR2(32000);

  l_fnd_user_id    NUMBER;
  l_object_code    VARCHAR2(32000);
  l_object_id      VARCHAR2(32000);

  l_new_line_chr  VARCHAR2(60);

  TYPE refCur IS REF CURSOR;
  C_note_details refCur;

  l_source_code   VARCHAR2(32000);
  l_source_id     NUMBER;
  l_select_id    VARCHAR2(200);
  l_select_name  VARCHAR2(200);
  l_select_details  VARCHAR2(2000);
  l_from_table    VARCHAR2(200);
  l_where_clause  VARCHAR2(32000);
  l_source_name  VARCHAR2(60);
  l_notes_detail_size NUMBER;
  l_more_text    VARCHAR2(60);

  l_sql_stmt VARCHAR2(32767);
  l_max_page_size CONSTANT NUMBER := 32000;
  l_note_summary_index BINARY_INTEGER;

  l_length        number;
  l_object_code_tbl DBMS_SQL.VARCHAR2_TABLE;
  l_object_id_tbl   DBMS_SQL.VARCHAR2_TABLE;
  l_start       number;
  l_end         number;
  l_count       number;
  l_where_cond  varchar2(32767);
  l_sqlcode number;
  l_sqlerrm VARCHAR2(100);
  l_proc_name CONSTANT VARCHAR2(100) := 'GET_NOTES_SUMMARY';

  begin

  iex_debug_pub.LogMessage(l_proc_name || ':' || 'begin');

  l_fnd_user_id := p_user_id;
  l_object_code := p_object_code;
  l_object_id   := p_object_id;
  l_new_line_chr := p_new_line_chr;

  l_start       := 1;
  l_end         := 1;
  l_count       := 0;
  l_where_cond  := '1 = 2';
  l_note_summary_index := 0;

  l_length := LENGTH(l_object_code);
  l_end := instr(l_object_code, ',', l_start, 1);

  WHILE TRUE LOOP
    l_count := l_count + 1;

    if l_end <> 0 then
      l_object_code_tbl(l_count) := substr(l_object_code, l_start, l_end - l_start);
    else
      l_object_code_tbl(l_count) := substr(l_object_code, l_start, l_length - l_start + 1);
      exit;
    end if;

    l_start := l_end + 1;
    l_end := instr(l_object_code, ',', l_start, 1);
  END LOOP;

  iex_debug_pub.LogMessage(l_proc_name || ':' || 'after populating code table:' || l_count );
  l_start := 1;
  l_count := 0;
  l_length := LENGTH(l_object_id);
  l_end := instr(l_object_id, ',', l_start, 1);

  WHILE TRUE LOOP
    l_count := l_count + 1;

    if l_end <> 0 then
      l_object_id_tbl(l_count) := substr(l_object_id, l_start, l_end - l_start);
    else
      l_object_id_tbl(l_count) := substr(l_object_id, l_start, l_length - l_start + 1);
      exit;
    end if;

    l_start := l_end + 1;
    l_end := instr(l_object_id, ',', l_start, 1);
  END LOOP;

  iex_debug_pub.LogMessage(l_proc_name || ':' || 'after populating id table:' || l_count );
  l_curr_rec_size := 0;
  l_note_summary_size  := 0;
  l_curr_rec := null;
  l_note_summary := null;

  l_note_summary_index := 1;


  IF l_object_code_tbl.count = l_object_id_tbl.count THEN
    For I in 1..l_object_id_tbl.count LOOP
     l_count := I;
     l_where_cond := l_where_cond || ' OR (note_context_type LIKE ''' || l_object_code_tbl(i) || ''' AND note_context_type_id = ' || l_object_id_tbl(i) || ')';
    END LOOP;

  ELSE

    l_where_cond := l_where_cond || ' OR ((note_context_type LIKE ''' || l_object_code_tbl(1) || ''') AND (';

    For I in 1..l_object_id_tbl.count LOOP
     l_count := I;
      IF I > 1 THEN
        l_where_cond := l_where_cond || ' OR note_context_type_id = ' || l_object_id_tbl(i);
      ELSE
        l_where_cond := l_where_cond || 'note_context_type_id = ' || l_object_id_tbl(i);
      END IF;

    END LOOP;

    l_where_cond := l_where_cond || ')) ';


  END IF;

  l_length := length(l_where_cond);
  iex_debug_pub.LogMessage(l_proc_name ||  ':after create l_where_cond:' || l_count || ':' || l_length);

  l_sql_stmt := 'SELECT a.notes, a.created_by_name, a.creation_date, ' ||
                ' a.note_type_meaning, a.note_status_meaning, ' ||
                ' a.source_object_id, a.source_object_code, ' ||
                ' b.select_id, b.select_name, b.select_details, ' ||
                ' b.from_table, b.where_clause, tl.name, a.notes_detail_size ' ||
                'FROM iex_notes_bali_vl a, ' ||
                ' jtf_objects_b b, jtf_objects_tl tl ' ||
                'WHERE (a.note_status <> ''P'' or a.created_by = ' || l_fnd_user_id || ') ' ||
                'AND a.source_object_code = b.object_code ' ||
                'AND b.object_code = tl.object_code ' ||
                'AND tl.language = userenv(''LANG'') ' ||
                'AND a.jtf_note_id IN (SELECT jtf_note_id FROM jtf_note_contexts WHERE ' ;

  l_length := length(l_sql_stmt);
  iex_debug_pub.LogMessage(l_proc_name || ':before create l_sql_stmt:' || l_count,  l_length);

  l_sql_stmt := l_sql_stmt || l_where_cond || ') ' ||
                'ORDER BY a.creation_date';

  IF p_summary_order = 'D' THEN
    l_sql_stmt := l_sql_stmt || ' DESC' ;
  END IF;

  iex_debug_pub.LogMessage(l_proc_name || ':after create l_sql_stmt:' || l_count || ':' ||  l_length);

  -- dbms_output.put_line(length(l_sql_stmt));
  -- dbms_output.put_line(substr(l_sql_stmt,1,200));
  -- dbms_output.put_line(substr(l_sql_stmt,201,200));
  -- dbms_output.put_line(substr(l_sql_stmt,401,200));
  -- dbms_output.put_line(substr(l_sql_stmt,601));

  OPEN C_note_details for l_sql_stmt;

  LOOP
    fetch C_note_details INTO
          l_notes,
          l_created_by_name,
          l_entered_date,
          l_note_type_meaning,
          l_note_status_meaning,
          l_source_id,
          l_source_code,
          l_select_id,
          l_select_name,
          l_select_details,
          l_from_table,
          l_where_clause,
          l_source_name,
          l_notes_detail_size;
    if C_note_details%FOUND then
      l_curr_rec := l_new_line_chr || to_char(l_entered_date,'DD-MON-RRRR HH:MI:SS') || ' *** ' ||
          l_created_by_name || ' *** ' || l_note_type_meaning ||
          ' *** ' || l_source_name || ': ' ||
          ast_note_package.note_context_info(
            l_select_id, l_select_name, l_select_details,
            l_from_table, l_where_clause, l_source_id) ||
          ' (ID:' || l_source_id || ')' ||
          l_new_line_chr || l_notes;
      if nvl(l_notes_detail_size,0) > 0 then
          l_curr_rec := l_curr_rec || '   <...>';
      end if;

      l_curr_rec := l_curr_rec  || l_new_line_chr || l_new_line_chr;

      l_curr_rec_size := length(l_curr_rec);

      if (l_note_summary_size + l_curr_rec_size) > l_max_page_size then
         x_notes_summary_tbl(l_note_summary_index) := l_note_summary;
         l_note_summary_index := l_note_summary_index + 1;
         l_note_summary := l_curr_rec;
         l_note_summary_size := l_curr_rec_size;
      else
         l_note_summary := l_note_summary || l_curr_rec;
         l_note_summary_size := l_note_summary_size + l_curr_rec_size;
      end if;
    else
      if l_note_summary_size <> 0 then
        x_notes_summary_tbl(l_note_summary_index) := l_note_summary;
      else
        l_note_summary_index := l_note_summary_index - 1;
      end if;
      exit;
    end if;
  END LOOP;
  close C_note_details;
EXCEPTION
  WHEN OTHERS THEN
    l_sqlcode := SQLCODE;
    iex_debug_pub.LogMessage(l_proc_name || ':Error' || l_sqlcode);
    iex_debug_pub.LogMessage(l_proc_name || ':l_count=' || to_char(l_count));
    l_length := length(l_where_cond);
    iex_debug_pub.LogMessage(l_proc_name || ':l_where_cond=' , l_length);
    l_length := length(l_sql_stmt);
    iex_debug_pub.LogMessage(l_proc_name || ':l_sql_stmt=' , l_length);
END Get_Notes_Summary;

FUNCTION GET_NOTE_HISTORY(p_jtf_note_id NUMBER)
RETURN VARCHAR2 IS
-- Begin fix bug #4930438-fix performance bug to remove MERGE JOIN CARTESIAN
--   CURSOR c_note_trx(x_jtf_note_id NUMBER) IS
--     SELECT ps.trx_number
--     FROM ast_notes_bali_vl notes, ar_payment_schedules ps
--     WHERE jtf_note_id = x_jtf_note_id
--     AND object_code = 'IEX_INVOICES'
--     AND ps.payment_schedule_id = object_id;
--
--   CURSOR c_note_party(x_jtf_note_id NUMBER) IS
--     SELECT p.party_name
--     FROM ast_notes_bali_vl notes, hz_parties p
--     WHERE jtf_note_id = x_jtf_note_id
--     AND object_code = 'PARTY'
--     AND object_id = p.party_id
--     AND p.party_type = 'ORGANIZATION';

  CURSOR c_note_trx(x_jtf_note_id NUMBER) IS
    SELECT ps.trx_number
    FROM jtf_note_contexts notes, ar_payment_schedules ps
    WHERE jtf_note_id = x_jtf_note_id
    AND note_context_type = 'IEX_INVOICES'
    AND ps.payment_schedule_id = note_context_type_id;

  CURSOR c_note_party(x_jtf_note_id NUMBER) IS
    SELECT p.party_name
    FROM jtf_note_contexts notes, hz_parties p
    WHERE jtf_note_id = x_jtf_note_id
    AND note_context_type = 'PARTY'
    AND note_context_type_id = p.party_id
    AND p.party_type = 'ORGANIZATION';
-- End fix bug #4930438-fix performance bug to remove MERGE JOIN CARTESIAN

  l_trx_number VARCHAR2(20);
  l_party_name VARCHAR2(360);
BEGIN
  OPEN c_note_trx(p_jtf_note_id);
  FETCH c_note_trx INTO l_trx_number;
  CLOSE c_note_trx;

  IF l_trx_number IS NOT NULL THEN
    RETURN l_trx_number;
  END IF;

  OPEN c_note_party(p_jtf_note_id);
  FETCH c_note_party INTO l_party_name;
  CLOSE c_note_party;

  RETURN l_party_name;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN
G_APPL_ID := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID := FND_GLOBAL.Conc_Program_Id;
G_REQUEST_ID := FND_GLOBAL.Conc_Request_Id;

PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_NOTES_PVT;

/
