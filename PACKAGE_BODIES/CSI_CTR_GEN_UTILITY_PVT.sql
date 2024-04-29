--------------------------------------------------------
--  DDL for Package Body CSI_CTR_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CTR_GEN_UTILITY_PVT" AS
/* $Header: csivctub.pls 120.7.12010000.2 2008/10/31 21:28:21 rsinn ship $ */

-- G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSI_CTR_GEN_UTILITY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivctub.pls';

FUNCTION G_MISS_NUM RETURN NUMBER IS
BEGIN
  RETURN FND_API.G_MISS_NUM ;
END G_MISS_NUM ;


FUNCTION G_MISS_CHAR RETURN VARCHAR2 IS
BEGIN
  RETURN FND_API.G_MISS_CHAR ;
END G_MISS_CHAR ;


FUNCTION G_MISS_DATE RETURN DATE IS
BEGIN
  RETURN FND_API.G_MISS_DATE ;
END G_MISS_DATE ;


PROCEDURE read_debug_profiles IS
   BEGIN
     g_debug_level         := fnd_profile.value('CSI_DEBUG_LEVEL');
     g_debug_file          := fnd_profile.value('CSI_LOGFILE_NAME');
     g_debug_file_path     := fnd_profile.value('CSI_LOGFILE_PATH');
     g_stop_on_debug_error := fnd_profile.value('CSI_STOP_AT_DEBUG_ERROR');
END read_debug_profiles;

PROCEDURE put_line(p_message IN VARCHAR2)
IS
   l_message               VARCHAR2(4000);
   l_sid                   NUMBER;
   l_os_user               VARCHAR2(30);
   l_file_handle           utl_file.file_type;

   -- l_log_file              VARCHAR2(30)  := fnd_profile.value('CSI_LOGFILE_NAME'); -- Bug 7197402
   -- l_log_file_path         VARCHAR2(240) := fnd_profile.value('CSI_LOGFILE_PATH'); -- Bug 7197402
   -- l_stop_on_debug_error   VARCHAR2(10)  := fnd_profile.value('CSI_STOP_AT_DEBUG_ERROR'); -- Bug 7197402

   -- l_debug_level           NUMBER := fnd_profile.value('CSI_DEBUG_LEVEL'); -- Bug 7197402
   l_log_file              VARCHAR2(30);
   l_instr                 NUMBER;
BEGIN
  -- Added for the bug 7197402
  IF (g_debug_level is null) THEN
		read_debug_profiles;
	END IF;

   IF (g_debug_level > 0) THEN
      IF g_sid is NULL THEN
         SELECT sid, osuser
         INTO   l_sid, l_os_user
         FROM   v$session
         WHERE  audsid = (SELECT userenv('SESSIONID') FROM dual);
         --
         g_sid := l_sid;
         g_osuser := l_os_user;
      END IF;

      l_message := g_osuser||'-'||g_sid||'-'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'-'||p_message;

      BEGIN
         SELECT instr(g_debug_file,'.')
         INTO   l_instr
         FROM   dual;
      EXCEPTION
         WHEN OTHERS THEN
            l_instr := 0;
      END;

      IF l_instr = 0 THEN
         l_log_file := g_debug_file||'-counter';
      ELSE
         BEGIN
            SELECT substr(g_debug_file,1,l_instr-1)||'-counter'||substr(g_debug_file,l_instr)
            INTO   l_log_file
            FROM   dual;
         EXCEPTION
            WHEN OTHERS THEN
               null;
         END;
      END IF;

      l_file_handle := UTL_FILE.FOPEN(g_debug_file_path, l_log_file, 'a');
      UTL_FILE.PUT_LINE (l_file_handle, l_message);
      UTL_FILE.FFLUSH(l_file_handle);
      UTL_FILE.FCLOSE(l_file_handle);
   END IF;
EXCEPTION
   WHEN UTL_FILE.INVALID_PATH THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_CTR_API_INVALID_PATH');
       FND_MSG_PUB.ADD;

       IF (g_stop_on_debug_error = 'Y') THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   WHEN UTL_FILE.INVALID_MODE THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_CTR_API_INVALID_MODE');
       FND_MSG_PUB.ADD;
       IF (g_stop_on_debug_error = 'Y') THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_CTR_API_INVALID_FILEHANDLE');
       FND_MSG_PUB.ADD;
       IF (g_stop_on_debug_error = 'Y') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

   WHEN UTL_FILE.INVALID_OPERATION THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_CTR_API_INVALID_OPERATION');
       FND_MSG_PUB.ADD;
       IF (g_stop_on_debug_error = 'Y') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

   WHEN UTL_FILE.WRITE_ERROR THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_CTR_API_WRITE_ERROR');
       FND_MSG_PUB.ADD;
       IF (g_stop_on_debug_error = 'Y') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

    WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CSI', 'CSI_CTR_API_PUT_LINE_ERROR');
       FND_MSG_PUB.ADD;
       IF (g_stop_on_debug_error = 'Y') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
END put_line;

Procedure ExitWithErrMsg
(   p_msg_name		in	varchar2,
    p_token1_name	in	varchar2	:=	null,
    p_token1_val	in	varchar2	:=	null,
    p_token2_name	in	varchar2	:=	null,
    p_token2_val	in	varchar2	:=	null,
    p_token3_name	in	varchar2	:=	null,
    p_token3_val	in	varchar2	:=	null,
    p_token4_name	in	varchar2	:=	null,
    p_token4_val	in	varchar2	:=	null
) IS
BEGIN
   FND_MESSAGE.SET_NAME('CSI',p_msg_name);
   IF p_token1_name is not null then
      FND_MESSAGE.SET_TOKEN(p_token1_name, p_token1_val);
   END IF;

   IF p_token2_name is not null then
      FND_MESSAGE.SET_TOKEN(p_token2_name, p_token2_val);
   END IF;

   IF p_token3_name is not null then
      FND_MESSAGE.SET_TOKEN(p_token3_name, p_token3_val);
   END IF;

   IF p_token4_name is not null then
      FND_MESSAGE.SET_TOKEN(p_token4_name, p_token4_val);
   END IF;
   --

   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END ExitWithErrMsg;

PROCEDURE Initialize_Desc_Flex
(   p_desc_flex	IN OUT NOCOPY  csi_ctr_datastructures_pub.dff_rec_type
) IS

BEGIN
   IF p_desc_flex.attribute_category = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute_category := NULL;
   ELSE
      p_desc_flex.attribute_category := p_desc_flex.attribute_category;
   END IF;

   IF p_desc_flex.attribute1 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute1 := NULL;
   ELSE
      p_desc_flex.attribute1 := p_desc_flex.attribute1;
	END IF;

   IF p_desc_flex.attribute2 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute2 := NULL;
   ELSE
      p_desc_flex.attribute2 := p_desc_flex.attribute2;
   END IF;

   IF p_desc_flex.attribute3 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute3 := NULL;
   ELSE
      p_desc_flex.attribute3 := p_desc_flex.attribute3;
   END IF;

   IF p_desc_flex.attribute4 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute4 := NULL;
   ELSE
      p_desc_flex.attribute4 := p_desc_flex.attribute4;
   END IF;

   IF p_desc_flex.attribute5 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute5 := NULL;
   ELSE
      p_desc_flex.attribute5 := p_desc_flex.attribute5;
   END IF;

   IF p_desc_flex.attribute6 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute6 := NULL;
   ELSE
      p_desc_flex.attribute6 := p_desc_flex.attribute6;
   END IF;

   IF p_desc_flex.attribute7 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute7 := NULL;
   ELSE
      p_desc_flex.attribute7 := p_desc_flex.attribute7;
   END IF;

   IF p_desc_flex.attribute8 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute8 := NULL;
   ELSE
      p_desc_flex.attribute8 := p_desc_flex.attribute8;
   END IF;

   IF p_desc_flex.attribute9 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute9 := NULL;
   ELSE
      p_desc_flex.attribute9 := p_desc_flex.attribute9;
   END IF;

   IF p_desc_flex.attribute10 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute10 := NULL;
   ELSE
      p_desc_flex.attribute10 := p_desc_flex.attribute10;
   END IF;

   IF p_desc_flex.attribute11 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute11 := NULL;
   ELSE
      p_desc_flex.attribute11 := p_desc_flex.attribute11;
   END IF;

   IF p_desc_flex.attribute12 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute12 := NULL;
   ELSE
      p_desc_flex.attribute12 := p_desc_flex.attribute12;
   END IF;

   IF p_desc_flex.attribute13 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute13 := NULL;
   ELSE
      p_desc_flex.attribute13 := p_desc_flex.attribute13;
   END IF;

   IF p_desc_flex.attribute14 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute14 := NULL;
   ELSE
      p_desc_flex.attribute14 := p_desc_flex.attribute14;
   END IF;

   IF p_desc_flex.attribute15 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute15 := NULL;
   ELSE
      p_desc_flex.attribute15 := p_desc_flex.attribute15;
   END IF;

   IF p_desc_flex.attribute16 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute16 := NULL;
   ELSE
      p_desc_flex.attribute16 := p_desc_flex.attribute16;
   END IF;

   IF p_desc_flex.attribute17 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute17 := NULL;
   ELSE
      p_desc_flex.attribute17 := p_desc_flex.attribute17;
   END IF;

   IF p_desc_flex.attribute18 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute18 := NULL;
   ELSE
      p_desc_flex.attribute18 := p_desc_flex.attribute18;
   END IF;

   IF p_desc_flex.attribute19 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute19 := NULL;
   ELSE
      p_desc_flex.attribute19 := p_desc_flex.attribute19;
   END IF;

   IF p_desc_flex.attribute20 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute20 := NULL;
   ELSE
      p_desc_flex.attribute20 := p_desc_flex.attribute20;
   END IF;

   IF p_desc_flex.attribute21 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute21 := NULL;
   ELSE
      p_desc_flex.attribute21 := p_desc_flex.attribute21;
   END IF;

   IF p_desc_flex.attribute22 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute22 := NULL;
   ELSE
      p_desc_flex.attribute22 := p_desc_flex.attribute22;
   END IF;

   IF p_desc_flex.attribute23 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute23 := NULL;
   ELSE
      p_desc_flex.attribute23 := p_desc_flex.attribute23;
   END IF;

   IF p_desc_flex.attribute24 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute24 := NULL;
   ELSE
      p_desc_flex.attribute24 := p_desc_flex.attribute24;
   END IF;

   IF p_desc_flex.attribute25 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute25 := NULL;
   ELSE
      p_desc_flex.attribute25 := p_desc_flex.attribute25;
   END IF;

   IF p_desc_flex.attribute26 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute26 := NULL;
   ELSE
      p_desc_flex.attribute26 := p_desc_flex.attribute26;
   END IF;

   IF p_desc_flex.attribute27 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute27 := NULL;
   ELSE
      p_desc_flex.attribute27 := p_desc_flex.attribute27;
   END IF;

   IF p_desc_flex.attribute28 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute28 := NULL;
   ELSE
      p_desc_flex.attribute28 := p_desc_flex.attribute28;
   END IF;

   IF p_desc_flex.attribute29 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute29 := NULL;
   ELSE
      p_desc_flex.attribute29 := p_desc_flex.attribute29;
   END IF;

   IF p_desc_flex.attribute30 = FND_API.G_MISS_CHAR THEN
      p_desc_flex.attribute30 := NULL;
   ELSE
      p_desc_flex.attribute30 := p_desc_flex.attribute30;
   END IF;
END Initialize_Desc_Flex;

PROCEDURE Is_DescFlex_Valid
(
   p_api_name			IN	VARCHAR2,
   p_appl_short_name		IN	VARCHAR2	:=	'CSI',
   p_desc_flex_name		IN	VARCHAR2,
   p_seg_partial_name		IN	VARCHAR2,
   p_num_of_attributes		IN	NUMBER,
   p_seg_values			IN	csi_ctr_datastructures_pub.dff_rec_type,
   p_stack_err_msg		IN	BOOLEAN	:=	TRUE
) IS

   p_desc_context	VARCHAR2(30);
   p_desc_col_name1	VARCHAR2(30)	:=	p_seg_partial_name||'1';
   p_desc_col_name2	VARCHAR2(30)	:=	p_seg_partial_name||'2';
   p_desc_col_name3	VARCHAR2(30)	:=	p_seg_partial_name||'3';
   p_desc_col_name4	VARCHAR2(30)	:=	p_seg_partial_name||'4';
   p_desc_col_name5	VARCHAR2(30)	:=	p_seg_partial_name||'5';
   p_desc_col_name6	VARCHAR2(30)	:=	p_seg_partial_name||'6';
   p_desc_col_name7	VARCHAR2(30)	:=	p_seg_partial_name||'7';
   p_desc_col_name8	VARCHAR2(30)	:=	p_seg_partial_name||'8';
   p_desc_col_name9	VARCHAR2(30)	:=	p_seg_partial_name||'9';
   p_desc_col_name10	VARCHAR2(30)	:=	p_seg_partial_name||'10';
   p_desc_col_name11	VARCHAR2(30)	:=	p_seg_partial_name||'11';
   p_desc_col_name12	VARCHAR2(30)	:=	p_seg_partial_name||'12';
   p_desc_col_name13	VARCHAR2(30)	:=	p_seg_partial_name||'13';
   p_desc_col_name14	VARCHAR2(30)	:=	p_seg_partial_name||'14';
   p_desc_col_name15	VARCHAR2(30)	:=	p_seg_partial_name||'15';
   p_desc_col_name16	VARCHAR2(30)	:=	p_seg_partial_name||'16';
   p_desc_col_name17	VARCHAR2(30)	:=	p_seg_partial_name||'17';
   p_desc_col_name18	VARCHAR2(30)	:=	p_seg_partial_name||'18';
   p_desc_col_name19	VARCHAR2(30)	:=	p_seg_partial_name||'19';
   p_desc_col_name20	VARCHAR2(30)	:=	p_seg_partial_name||'20';
   p_desc_col_name21	VARCHAR2(30)	:=	p_seg_partial_name||'21';
   p_desc_col_name22	VARCHAR2(30)	:=	p_seg_partial_name||'22';
   p_desc_col_name23	VARCHAR2(30)	:=	p_seg_partial_name||'23';
   p_desc_col_name24	VARCHAR2(30)	:=	p_seg_partial_name||'24';
   p_desc_col_name25	VARCHAR2(30)	:=	p_seg_partial_name||'25';
   p_desc_col_name26	VARCHAR2(30)	:=	p_seg_partial_name||'26';
   p_desc_col_name27	VARCHAR2(30)	:=	p_seg_partial_name||'27';
   p_desc_col_name28	VARCHAR2(30)	:=	p_seg_partial_name||'28';
   p_desc_col_name29	VARCHAR2(30)	:=	p_seg_partial_name||'29';
   p_desc_col_name30	VARCHAR2(30)	:=	p_seg_partial_name||'30';
   l_return_status	VARCHAR2(1);
   l_resp_appl_id	NUMBER;
   l_resp_id		NUMBER;
   l_return_value	BOOLEAN		:=	TRUE;

BEGIN
   IF p_num_of_attributes > 30 THEN
      /* More than 15 attributes not currently supported. Please contact developer. */
      ExitWithErrMsg('CSI_API_NUM_OF_DESCFLEX_GT_MAX');
   END IF;

   Validate_Desc_Flex
      (	p_api_name,
	p_appl_short_name,
      	p_desc_flex_name,
      	p_desc_col_name1,
      	p_desc_col_name2,
      	p_desc_col_name3,
      	p_desc_col_name4,
      	p_desc_col_name5,
      	p_desc_col_name6,
      	p_desc_col_name7,
      	p_desc_col_name8,
      	p_desc_col_name9,
      	p_desc_col_name10,
      	p_desc_col_name11,
      	p_desc_col_name12,
      	p_desc_col_name13,
      	p_desc_col_name14,
      	p_desc_col_name15,
      	p_desc_col_name16,
      	p_desc_col_name17,
      	p_desc_col_name18,
      	p_desc_col_name19,
      	p_desc_col_name20,
      	p_desc_col_name21,
      	p_desc_col_name22,
      	p_desc_col_name23,
      	p_desc_col_name24,
      	p_desc_col_name25,
      	p_desc_col_name26,
      	p_desc_col_name27,
      	p_desc_col_name28,
      	p_desc_col_name29,
      	p_desc_col_name30,
      	p_seg_values.attribute1,
      	p_seg_values.attribute2,
      	p_seg_values.attribute3,
      	p_seg_values.attribute4,
      	p_seg_values.attribute5,
      	p_seg_values.attribute6,
      	p_seg_values.attribute7,
      	p_seg_values.attribute8,
      	p_seg_values.attribute9,
      	p_seg_values.attribute10,
      	p_seg_values.attribute11,
      	p_seg_values.attribute12,
      	p_seg_values.attribute13,
      	p_seg_values.attribute14,
      	p_seg_values.attribute15,
        p_seg_values.attribute16,
      	p_seg_values.attribute17,
      	p_seg_values.attribute18,
      	p_seg_values.attribute19,
      	p_seg_values.attribute20,
      	p_seg_values.attribute21,
      	p_seg_values.attribute22,
      	p_seg_values.attribute23,
      	p_seg_values.attribute24,
      	p_seg_values.attribute25,
      	p_seg_values.attribute26,
      	p_seg_values.attribute27,
      	p_seg_values.attribute28,
      	p_seg_values.attribute29,
      	p_seg_values.attribute30,
      	p_seg_values.attribute_category,
      	l_resp_appl_id,
      	l_resp_id,
      	l_return_status );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      RAISE FND_API.G_EXC_ERROR;
   end if;
END Is_DescFlex_Valid;

------------------------------------------------------------------------------
--  Procedure	: Validate_Desc_Flex
------------------------------------------------------------------------------


PROCEDURE Validate_Desc_Flex
  ( p_api_name		IN	VARCHAR2,
    p_appl_short_name	IN	VARCHAR2,
    p_desc_flex_name	IN	VARCHAR2,
    p_column_name1	IN	VARCHAR2,
    p_column_name2	IN	VARCHAR2,
    p_column_name3	IN	VARCHAR2,
    p_column_name4	IN	VARCHAR2,
    p_column_name5	IN	VARCHAR2,
    p_column_name6	IN	VARCHAR2,
    p_column_name7	IN	VARCHAR2,
    p_column_name8	IN	VARCHAR2,
    p_column_name9	IN	VARCHAR2,
    p_column_name10	IN	VARCHAR2,
    p_column_name11	IN	VARCHAR2,
    p_column_name12	IN	VARCHAR2,
    p_column_name13	IN	VARCHAR2,
    p_column_name14	IN	VARCHAR2,
    p_column_name15	IN	VARCHAR2,
    p_column_name16	IN	VARCHAR2,
    p_column_name17	IN	VARCHAR2,
    p_column_name18	IN	VARCHAR2,
    p_column_name19	IN	VARCHAR2,
    p_column_name20	IN	VARCHAR2,
    p_column_name21	IN	VARCHAR2,
    p_column_name22	IN	VARCHAR2,
    p_column_name23	IN	VARCHAR2,
    p_column_name24	IN	VARCHAR2,
    p_column_name25	IN	VARCHAR2,
    p_column_name26	IN	VARCHAR2,
    p_column_name27	IN	VARCHAR2,
    p_column_name28	IN	VARCHAR2,
    p_column_name29	IN	VARCHAR2,
    p_column_name30	IN	VARCHAR2,
    p_column_value1	IN	VARCHAR2,
    p_column_value2	IN	VARCHAR2,
    p_column_value3	IN	VARCHAR2,
    p_column_value4	IN	VARCHAR2,
    p_column_value5	IN	VARCHAR2,
    p_column_value6	IN	VARCHAR2,
    p_column_value7	IN	VARCHAR2,
    p_column_value8	IN	VARCHAR2,
    p_column_value9	IN	VARCHAR2,
    p_column_value10	IN	VARCHAR2,
    p_column_value11	IN	VARCHAR2,
    p_column_value12	IN	VARCHAR2,
    p_column_value13	IN	VARCHAR2,
    p_column_value14	IN	VARCHAR2,
    p_column_value15	IN	VARCHAR2,
    p_column_value16	IN	VARCHAR2,
    p_column_value17	IN	VARCHAR2,
    p_column_value18	IN	VARCHAR2,
    p_column_value19	IN	VARCHAR2,
    p_column_value20	IN	VARCHAR2,
    p_column_value21	IN	VARCHAR2,
    p_column_value22	IN	VARCHAR2,
    p_column_value23	IN	VARCHAR2,
    p_column_value24	IN	VARCHAR2,
    p_column_value25	IN	VARCHAR2,
    p_column_value26	IN	VARCHAR2,
    p_column_value27	IN	VARCHAR2,
    p_column_value28	IN	VARCHAR2,
    p_column_value29	IN	VARCHAR2,
    p_column_value30	IN	VARCHAR2,
    p_context_value	IN	VARCHAR2,
    p_resp_appl_id	IN	NUMBER,
    p_resp_id		IN	NUMBER,
    x_return_status	OUT	NOCOPY VARCHAR2 ) IS

   l_error_message	VARCHAR2(2000);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   fnd_flex_descval.set_column_value(p_column_name1, p_column_value1);
   fnd_flex_descval.set_column_value(p_column_name2, p_column_value2);
   fnd_flex_descval.set_column_value(p_column_name3, p_column_value3);
   fnd_flex_descval.set_column_value(p_column_name4, p_column_value4);
   fnd_flex_descval.set_column_value(p_column_name5, p_column_value5);
   fnd_flex_descval.set_column_value(p_column_name6, p_column_value6);
   fnd_flex_descval.set_column_value(p_column_name7, p_column_value7);
   fnd_flex_descval.set_column_value(p_column_name8, p_column_value8);
   fnd_flex_descval.set_column_value(p_column_name9, p_column_value9);
   fnd_flex_descval.set_column_value(p_column_name10, p_column_value10);
   fnd_flex_descval.set_column_value(p_column_name11, p_column_value11);
   fnd_flex_descval.set_column_value(p_column_name12, p_column_value12);
   fnd_flex_descval.set_column_value(p_column_name13, p_column_value13);
   fnd_flex_descval.set_column_value(p_column_name14, p_column_value14);
   fnd_flex_descval.set_column_value(p_column_name15, p_column_value15);
   fnd_flex_descval.set_column_value(p_column_name16, p_column_value16);
   fnd_flex_descval.set_column_value(p_column_name17, p_column_value17);
   fnd_flex_descval.set_column_value(p_column_name18, p_column_value18);
   fnd_flex_descval.set_column_value(p_column_name19, p_column_value19);
   fnd_flex_descval.set_column_value(p_column_name20, p_column_value20);
   fnd_flex_descval.set_column_value(p_column_name21, p_column_value21);
   fnd_flex_descval.set_column_value(p_column_name22, p_column_value22);
   fnd_flex_descval.set_column_value(p_column_name23, p_column_value23);
   fnd_flex_descval.set_column_value(p_column_name24, p_column_value24);
   fnd_flex_descval.set_column_value(p_column_name25, p_column_value25);
   fnd_flex_descval.set_column_value(p_column_name26, p_column_value26);
   fnd_flex_descval.set_column_value(p_column_name27, p_column_value27);
   fnd_flex_descval.set_column_value(p_column_name28, p_column_value28);
   fnd_flex_descval.set_column_value(p_column_name29, p_column_value29);
   fnd_flex_descval.set_column_value(p_column_name30, p_column_value30);
   fnd_flex_descval.set_context_value(p_context_value);

   IF NOT fnd_flex_descval.validate_desccols
      ( appl_short_name	=> p_appl_short_name,
        desc_flex_name	=> p_desc_flex_name,
        resp_appl_id	=> p_resp_appl_id,
        resp_id		=> p_resp_id ) THEN
        l_error_message := fnd_flex_descval.error_message;
        -- add_desc_flex_msg(p_api_name, l_error_message);
        x_return_status := fnd_api.g_ret_sts_error;
   END IF;
END Validate_Desc_Flex;

PROCEDURE VALIDATE_FORMULA_CTR
(
   p_api_version        IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2	:= FND_API.G_FALSE,
   p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
   p_validation_level	IN	VARCHAR2	:= FND_API.G_VALID_LEVEL_FULL,
   x_return_status		OUT	NOCOPY VARCHAR2,
   x_msg_count		OUT     NOCOPY  NUMBER,
   x_msg_data		OUT     NOCOPY  VARCHAR2,
   p_counter_id		IN	NUMBER,
   x_valid_flag		OUT     NOCOPY  VARCHAR2
) is

   l_api_name           CONSTANT VARCHAR2(30) := 'VALIDATE_FORMULA_CTR';
   l_api_version        CONSTANT NUMBER   := 1.0;
   l_return_status_full      VARCHAR2(1);
   l_s_temp                  VARCHAR2(100);

   -- Cursor to select all bind variables in bvars table for passed counter
   CURSOR ctr_bvars IS
   SELECT bind_variable_name
   FROM csi_counter_relationships
   WHERE object_counter_id  = p_counter_id;

   l_cursor_handle   INTEGER;
   l_n_temp          INTEGER;
   l_formula         varchar2(255);
   l_counter_reading NUMBER;
   l_bind_var_value  NUMBER;
   l_bind_var_name   VARCHAR2(255);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_FORMULA;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                            	       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body

   -- ******************************************************************
   -- Validate Environment
   -- ******************************************************************

   IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      -- Invoke validation procedures
      null;
   END IF;

   --Validate counter group id only when validation level is not none
   IF ( p_validation_level > FND_API.G_VALID_LEVEL_NONE)
   THEN
      null;
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Parameter Validations and initialization

   x_valid_flag := 'N';

   BEGIN
      SELECT formula_text
      INTO   l_formula
      FROM   csi_counters_v
      WHERE  counter_id = p_counter_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ExitWithErrMsg('CSI_API_CTR_INVALID');
   END;

   -- Debug Message
   --Start Process
   BEGIN
      --Open the cursor
      l_cursor_handle := dbms_sql.open_cursor;
      l_formula := 'SELECT '||l_formula||' FROM DUAL';

      -- parse the formula using dual table
      -- if formula is :a/2, in a sql statement it will become 'select :a/2 from dual'

      DBMS_SQL.PARSE(l_cursor_handle, l_formula, dbms_sql.native);

      --define column to select value

      DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_counter_reading);

      FOR bvars IN ctr_bvars LOOP
         l_bind_var_value := 100;
         l_bind_var_name := ':'||ltrim(bvars.bind_variable_name);
         DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_var_name, l_bind_var_value);
      END LOOP bvars;

      l_n_temp := dbms_sql.execute(l_cursor_handle);

      IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
         dbms_sql.column_value(l_cursor_handle,1,l_counter_reading);
         x_valid_flag := 'Y';
      END IF;

      DBMS_SQL.close_cursor(l_cursor_handle);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.IS_OPEN(l_cursor_handle) THEN
            DBMS_SQL.CLOSE_cursor(l_cursor_handle);
         END IF;

 	 if sqlcode <> -1008 then
            RAISE;
         else
	    x_valid_flag := 'N';
         end if;
   END;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- End of API body
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_FORMULA;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count,
            p_data => x_msg_data
           );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_FORMULA;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
           (
            p_count => x_msg_count,
            p_data => x_msg_data
           );
   WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_FORMULA;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
END VALIDATE_FORMULA_CTR;

PROCEDURE VALIDATE_GRPOP_CTR
(
    p_api_version	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2	:= FND_API.G_FALSE,
    p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
    p_validation_level	IN	VARCHAR2	:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT     NOCOPY VARCHAR2,
    x_msg_count		OUT	NOCOPY NUMBER,
    x_msg_data		OUT	NOCOPY VARCHAR2,
    p_counter_id	IN	NUMBER,
    x_valid_flag		OUT     NOCOPY VARCHAR2
) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_GRPOP_CTR';
   l_api_version             CONSTANT NUMBER   := 1.0;
   l_return_status_full      VARCHAR2(1);
   l_s_temp                  VARCHAR2(100);

   CURSOR ctrs_to_be_calc IS
   SELECT distinct ctr.counter_id, ctr.derive_function,
          ctr.derive_counter_id, ctr.derive_property_id
   FROM   csi_counters_bc_v ctr
   WHERE  ctr.counter_id = p_counter_id;

   CURSOR der_filters(b_counter_id number) IS
   SELECT filt.counter_property_id, filt.seq_no,filt.left_parent,
          filt.right_parent, filt.relational_operator,
          filt.logical_operator, filt.right_value,
          nvl(pro.default_value, 'NULL') as default_value,
          pro.property_data_type
   FROM   csi_counter_derived_filters filt, csi_ctr_properties_bc_v pro
   WHERE  filt.counter_id = b_counter_id
   AND    pro.counter_property_id(+) = filt.counter_property_id;

   l_sqlstr        varchar2(2000);
   l_sqlwhere      varchar2(1000);
   l_sqlfrom       varchar2(1000);
   l_cursor_handle NUMBER;
   l_ctr_value     NUMBER;
   l_n_temp        NUMBER;

   --variable and arrays for binding dbmssql
   TYPE FILTS IS RECORD(
   BINDNAME_DEFVAL    VARCHAR2(240),
   BINDVAL_DEFVAL     VARCHAR2(240),
   BINDNAME_RIGHTVAL  VARCHAR2(240),
   BINDVAL_RIGHTVAL   VARCHAR2(240),
   BINDNAME_CTRPROPID VARCHAR2(240),
   BINDVAL_CTRPROPID  NUMBER);

   TYPE T1 is TABLE OF FILTS index by binary_integer;
   T2 T1;
   i NUMBER := 1;
   lj NUMBER := 1;

   BINDVAL_DERIVECTRID NUMBER;
   l_bind_varname VARCHAR2(240);
   l_bind_varvalc  VARCHAR2(240);
   l_bind_varvaln  NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_GRPOP;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                        	        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
   -- ******************************************************************
   -- Validate Environment
   -- ******************************************************************

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      -- Invoke validation procedures
      null;
   END IF;

   --Validate counter group id only when validation level is not none
   IF ( P_validation_level > FND_API.G_VALID_LEVEL_NONE)
   THEN
      null;
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Parameter Validations and initialization
   x_valid_flag := 'N';

   -- Debug Message
   begin
      FOR ctrs IN ctrs_to_be_calc LOOP
          i := 1;
          lj := 1;

          l_sqlstr := 'select '||ctrs.derive_function||'( counter_reading )';
          l_sqlstr := l_sqlstr || ' from csi_counter_readings cv';
          l_sqlstr := l_sqlstr || ' where counter_value_id in (';
          l_sqlstr := l_sqlstr || ' select distinct cv.counter_value_id from ';
          l_sqlfrom := ' csi_counter_readings cv';
          l_sqlwhere := '';

          FOR filts IN der_filters(ctrs.counter_id) LOOP
             l_sqlfrom := l_sqlfrom ||', csi_ctr_property_readings pv';
             l_sqlfrom := l_sqlfrom ||ltrim(rtrim(filts.seq_no));

             if filts.seq_no > 1 then
                 l_sqlwhere := l_sqlwhere ||' and '||nvl(filts.left_parent,' ')||' nvl(pv';
             else
                 l_sqlwhere := l_sqlwhere ||' '||nvl(filts.left_parent,' ')||' nvl(pv';
             end if;

             l_sqlwhere := l_sqlwhere || ltrim(rtrim(filts.seq_no));
             l_sqlwhere := l_sqlwhere || '.property_value, '; --||filts.default_value;

             T2(i).BINDVAL_DEFVAL := filts.default_value;
             T2(i).BINDNAME_DEFVAL := ':x_default_value'||ltrim(rtrim(filts.seq_no));

             if filts.property_data_type = 'NUMBER' then
                l_sqlwhere := l_sqlwhere ||':x_default_value'||ltrim(rtrim(filts.seq_no));
             elsif filts.property_data_type = 'DATE' then
                -- l_sqlwhere := l_sqlwhere || 'to_date( '||':x_default_value'||ltrim(rtrim(filts.seq_no))||' )';
                l_sqlwhere := l_sqlwhere || 'to_date( '||':x_default_value'||ltrim(rtrim(filts.seq_no))||','||'''YYYY/MM/DD'''||')';
             else
                l_sqlwhere := l_sqlwhere || ':x_default_value'||ltrim(rtrim(filts.seq_no));
             end if;

             l_sqlwhere := l_sqlwhere ||')'||' '||filts.relational_operator;

             T2(i).BINDVAL_RIGHTVAL := filts.right_value;
             T2(i).BINDNAME_RIGHTVAL := ':x_right_value'||ltrim(rtrim(filts.seq_no));

             if filts.property_data_type = 'NUMBER' then
                l_sqlwhere := l_sqlwhere || ':x_right_value'||ltrim(rtrim(filts.seq_no));
             elsif filts.property_data_type = 'DATE' then
                -- l_sqlwhere := l_sqlwhere || 'to_date( '||':x_right_value'||ltrim(rtrim(filts.seq_no))||' )';
                l_sqlwhere := l_sqlwhere || 'to_date( '||':x_right_value'||ltrim(rtrim(filts.seq_no))||','||'''YYYY/MM/DD'''||')';
             else
                l_sqlwhere := l_sqlwhere || ':x_right_value'||ltrim(rtrim(filts.seq_no));
             end if;

             l_sqlwhere := l_sqlwhere || nvl(filts.right_parent,' ');
             l_sqlwhere := l_sqlwhere || ' '|| filts.logical_operator;
             if filts.seq_no > 1 then
                l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
             else
                if filts.logical_operator IS NULL THEN
                   l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
                else
                   l_sqlwhere := l_sqlwhere || ' pv'||ltrim(rtrim(filts.seq_no)) ;
                end if;
             end if;

             l_sqlwhere := l_sqlwhere || '.counter_value_id = cv.counter_value_id ';
             l_sqlwhere := l_sqlwhere || ' and pv'||ltrim(rtrim(filts.seq_no)) ;
             l_sqlwhere := l_sqlwhere || '.counter_property_id = ';

             T2(i).BINDVAL_CTRPROPID := filts.counter_property_id;
             T2(i).BINDNAME_CTRPROPID := ':x_ctr_prop_id'||ltrim(rtrim(filts.seq_no));
             l_sqlwhere := l_sqlwhere ||':x_ctr_prop_id'||ltrim(rtrim(filts.seq_no));

             l_sqlwhere := l_sqlwhere || ' and cv.counter_id = ';
             l_sqlwhere := l_sqlwhere || ':x_derive_counter_id';
          END LOOP;

          l_sqlstr := l_sqlstr || l_sqlfrom || ' where '||l_sqlwhere||')';

csi_ctr_gen_utility_pvt.put_line('l_sqlstr = '||l_sqlstr);

          l_cursor_handle := dbms_sql.open_cursor;
          DBMS_SQL.PARSE(l_cursor_handle, l_sqlstr, dbms_sql.native);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_ctr_value);

          BINDVAL_DERIVECTRID := ctrs.derive_counter_id;
          DBMS_SQL.BIND_VARIABLE(l_cursor_handle, ':x_derive_counter_id',BINDVAL_DERIVECTRID);

          while lj < i+1
          loop
             l_bind_varname := t2(lj).BINDNAME_DEFVAL;
             l_bind_varvalc := t2(lj).BINDVAL_DEFVAL;
             DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvalc);
             l_bind_varname := t2(lj).BINDNAME_RIGHTVAL;
             l_bind_varvalc := t2(lj).BINDVAL_RIGHTVAL;
             DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvalc);
             l_bind_varname := t2(lj).BINDNAME_CTRPROPID;
             l_bind_varvaln := t2(lj).BINDVAL_CTRPROPID;
             DBMS_SQL.BIND_VARIABLE(l_cursor_handle, l_bind_varname, l_bind_varvaln);
             lj:= lj+1;
          end loop;

          /* l_n_temp := dbms_sql.execute(l_cursor_handle);
          IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
              dbms_sql.column_value(l_cursor_handle,1,l_ctr_value);
          END IF;
          DBMS_SQL.close_cursor(l_cursor_handle);
          */
          x_valid_flag := 'Y';
       END LOOP;
    EXCEPTION
       WHEN OTHERS THEN
          IF DBMS_SQL.IS_OPEN(l_cursor_handle) THEN
             DBMS_SQL.CLOSE_cursor(l_cursor_handle);
          END IF;
          RAISE;
    END;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- End of API body
    --
    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
       COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
       (  p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_GRPOP;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count,
            p_data => x_msg_data
           );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_GRPOP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
           (
            p_count => x_msg_count,
            p_data => x_msg_data
           );
   WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_GRPOP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
End VALIDATE_GRPOP_CTR;

FUNCTION Is_StartEndDate_Valid
(
   p_st_dt            IN      DATE,
   p_end_dt           IN      DATE,
   p_stack_err_msg    IN      BOOLEAN := TRUE
) RETURN BOOLEAN IS

   l_return_value BOOLEAN := TRUE;
BEGIN
   IF (p_st_dt > p_end_dt) THEN
      l_return_value := FALSE;
      IF ( p_stack_err_msg = TRUE ) THEN
         ExitWithErrMsg('CSI_ALL_START_DATE_AFTER_END','START_DATE',p_st_dt,'END_DATE',p_end_dt);
		   FND_MSG_PUB.Add;
      END IF;
   END IF;
   RETURN l_return_value;
END Is_StartEndDate_Valid;

PROCEDURE Initialize_Desc_Flex_For_Upd
(
	l_ctr_derived_filters_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec,
	l_old_ctr_derived_filters_rec IN		CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec
) IS
BEGIN
	IF l_ctr_derived_filters_rec.attribute1 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute1 := l_old_ctr_derived_filters_rec.attribute1;
	END IF;

	IF l_ctr_derived_filters_rec.attribute2 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute2 := l_old_ctr_derived_filters_rec.attribute2;
	END IF;

	IF l_ctr_derived_filters_rec.attribute3 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute3 := l_old_ctr_derived_filters_rec.attribute3;
	END IF;

	IF l_ctr_derived_filters_rec.attribute4 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute4 := l_old_ctr_derived_filters_rec.attribute4;
	END IF;

	IF l_ctr_derived_filters_rec.attribute5 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute5 := l_old_ctr_derived_filters_rec.attribute5;
	END IF;

	IF l_ctr_derived_filters_rec.attribute6 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute6 := l_old_ctr_derived_filters_rec.attribute6;
	END IF;

	IF l_ctr_derived_filters_rec.attribute7 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute7 := l_old_ctr_derived_filters_rec.attribute7;
	END IF;

	IF l_ctr_derived_filters_rec.attribute8 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute8 := l_old_ctr_derived_filters_rec.attribute8;
	END IF;

	IF l_ctr_derived_filters_rec.attribute9 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute9 := l_old_ctr_derived_filters_rec.attribute9;
	END IF;

	IF l_ctr_derived_filters_rec.attribute10 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute10 := l_old_ctr_derived_filters_rec.attribute10;
	END IF;

	IF l_ctr_derived_filters_rec.attribute11 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute11 := l_old_ctr_derived_filters_rec.attribute11;
	END IF;

	IF l_ctr_derived_filters_rec.attribute12 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute12 := l_old_ctr_derived_filters_rec.attribute12;
	END IF;

	IF l_ctr_derived_filters_rec.attribute13 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute13 := l_old_ctr_derived_filters_rec.attribute13;
	END IF;

	IF l_ctr_derived_filters_rec.attribute14 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute14 := l_old_ctr_derived_filters_rec.attribute14;
	END IF;

	IF l_ctr_derived_filters_rec.attribute15 = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute15 := l_old_ctr_derived_filters_rec.attribute15;
	END IF;

	IF l_ctr_derived_filters_rec.attribute_category = FND_API.G_MISS_CHAR THEN
		l_ctr_derived_filters_rec.attribute_category := l_old_ctr_derived_filters_rec.attribute_category;
	END IF;
END Initialize_Desc_Flex_For_Upd;


PROCEDURE check_ib_active IS
BEGIN
   /* IF NOT csi_gen_utility_pvt.IB_ACTIVE THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_IB_NOT_ACTIVE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_Exc_Error;
   END IF
   */
   null;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
   WHEN others THEN
      FND_MESSAGE.Set_Name('CSI', 'CSI_UNEXP_SQL_ERROR');
      FND_MESSAGE.Set_Token('API_NAME', 'Check_IB_Active');
      FND_MESSAGE.Set_Token('SQL_ERROR', sqlerrm);
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_error;
END check_ib_active;

PROCEDURE dump_ctr_grp_rec
   (p_counter_groups_rec IN  csi_ctr_datastructures_pub.counter_groups_rec) IS

   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_grp_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
   SAVEPOINT      dump_ctr_grp_rec;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Groups Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_GROUP_ID                   :'||p_counter_groups_rec.COUNTER_GROUP_ID);
   PUT_LINE ('NAME                               :'||p_counter_groups_rec.NAME);
   PUT_LINE ('DESCRIPTION                        :'||p_counter_groups_rec.DESCRIPTION);
   PUT_LINE ('TEMPLATE_FLAG                      :'||p_counter_groups_rec.TEMPLATE_FLAG);
   -- PUT_LINE ('CP_SERVICE_ID                      :'||p_counter_groups_rec.CP_SERVICE_ID);
   -- PUT_LINE ('CUSTOMER_PRODUCT_ID                :'||p_counter_groups_rec.CUSTOMER_PRODUCT_ID);
   PUT_LINE ('START_DATE_ACTIVE                  :'||p_counter_groups_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE                    :'||p_counter_groups_rec.END_DATE_ACTIVE);
   PUT_LINE ('ATTRIBUTE1                         :'||p_counter_groups_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                         :'||p_counter_groups_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                         :'||p_counter_groups_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                         :'||p_counter_groups_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                         :'||p_counter_groups_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                         :'||p_counter_groups_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                         :'||p_counter_groups_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                         :'||p_counter_groups_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                         :'||p_counter_groups_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                        :'||p_counter_groups_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                        :'||p_counter_groups_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                        :'||p_counter_groups_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                        :'||p_counter_groups_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                        :'||p_counter_groups_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                        :'||p_counter_groups_rec.ATTRIBUTE15);
   PUT_LINE ('CONTEXT                            :'||p_counter_groups_rec.CONTEXT);
   PUT_LINE ('OBJECT_VERSION_NUMBER              :'||p_counter_groups_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('CREATED_FROM_CTR_GRP_TMPL_ID       :'||p_counter_groups_rec.CREATED_FROM_CTR_GRP_TMPL_ID);
   PUT_LINE ('ASSOCIATION_TYPE                   :'||p_counter_groups_rec.ASSOCIATION_TYPE);
   PUT_LINE ('SOURCE_OBJECT_CODE                 :'||p_counter_groups_rec.SOURCE_OBJECT_CODE);
   PUT_LINE ('SOURCE_OBJECT_ID                   :'||p_counter_groups_rec.SOURCE_OBJECT_ID);
   PUT_LINE ('SOURCE_COUNTER_GROUP_ID            :'||p_counter_groups_rec.SOURCE_COUNTER_GROUP_ID);
   PUT_LINE ('SECURITY_GROUP_ID                  :'||p_counter_groups_rec.SECURITY_GROUP_ID);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_grp_rec;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, l_api_name);
      END IF;
END dump_ctr_grp_rec;

PROCEDURE dump_ctr_grp_tbl
   (p_counter_groups_tbl IN  csi_ctr_datastructures_pub.counter_groups_tbl) IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'dump_ctr_grp_tbl';
   l_api_version CONSTANT NUMBER         := 1.0;
BEGIN
   SAVEPOINT dump_ctr_grp_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_counter_groups_tbl.COUNT > 0 THEN
      FOR tab_row IN p_counter_groups_tbl.FIRST .. p_counter_groups_tbl.LAST
      LOOP
         IF p_counter_groups_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Groups Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_GROUP_ID                   :'||p_counter_groups_tbl(tab_row).COUNTER_GROUP_ID);
	   PUT_LINE ('NAME                               :'||p_counter_groups_tbl(tab_row).NAME);
	   PUT_LINE ('DESCRIPTION                        :'||p_counter_groups_tbl(tab_row).DESCRIPTION);
	   PUT_LINE ('TEMPLATE_FLAG                      :'||p_counter_groups_tbl(tab_row).TEMPLATE_FLAG);
	   -- PUT_LINE ('CP_SERVICE_ID                      :'||p_counter_groups_tbl(tab_row).CP_SERVICE_ID);
	   -- PUT_LINE ('CUSTOMER_PRODUCT_ID                :'||p_counter_groups_tbl(tab_row).CUSTOMER_PRODUCT_ID);
	   PUT_LINE ('START_DATE_ACTIVE                  :'||p_counter_groups_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE                    :'||p_counter_groups_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('ATTRIBUTE1                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                         :'||p_counter_groups_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                        :'||p_counter_groups_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                        :'||p_counter_groups_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                        :'||p_counter_groups_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                        :'||p_counter_groups_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                        :'||p_counter_groups_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                        :'||p_counter_groups_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('CONTEXT                            :'||p_counter_groups_tbl(tab_row).CONTEXT);
	   PUT_LINE ('OBJECT_VERSION_NUMBER              :'||p_counter_groups_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('CREATED_FROM_CTR_GRP_TMPL_ID       :'||p_counter_groups_tbl(tab_row).CREATED_FROM_CTR_GRP_TMPL_ID);
	   PUT_LINE ('ASSOCIATION_TYPE                   :'||p_counter_groups_tbl(tab_row).ASSOCIATION_TYPE);
	   PUT_LINE ('SOURCE_OBJECT_CODE                 :'||p_counter_groups_tbl(tab_row).SOURCE_OBJECT_CODE);
	   PUT_LINE ('SOURCE_OBJECT_ID                   :'||p_counter_groups_tbl(tab_row).SOURCE_OBJECT_ID);
	   PUT_LINE ('SOURCE_COUNTER_GROUP_ID            :'||p_counter_groups_tbl(tab_row).SOURCE_COUNTER_GROUP_ID);
	   PUT_LINE ('SECURITY_GROUP_ID                  :'||p_counter_groups_tbl(tab_row).SECURITY_GROUP_ID);
        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_grp_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_grp_tbl;

PROCEDURE dump_ctr_template_rec
   (p_counter_template_rec IN  csi_ctr_datastructures_pub.counter_template_rec) IS


   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_template_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
   SAVEPOINT dump_ctr_template_rec;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Template Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_ID                         :'||p_counter_template_rec.COUNTER_ID);
   PUT_LINE ('GROUP_ID                           :'||p_counter_template_rec.GROUP_ID);
   PUT_LINE ('DESCRIPTION                        :'||p_counter_template_rec.DESCRIPTION);
   PUT_LINE ('COUNTER_TYPE                       :'||p_counter_template_rec.COUNTER_TYPE);
   PUT_LINE ('INITIAL_READING                    :'||p_counter_template_rec.INITIAL_READING);
   PUT_LINE ('INITIAL_READING_DATE               :'||p_counter_template_rec.INITIAL_READING_DATE);
   PUT_LINE ('TOLERANCE_PLUS                     :'||p_counter_template_rec.TOLERANCE_PLUS);
   PUT_LINE ('TOLERANCE_MINUS                    :'||p_counter_template_rec.TOLERANCE_MINUS);
   PUT_LINE ('UOM_CODE                           :'||p_counter_template_rec.UOM_CODE);
   PUT_LINE ('DERIVE_COUNTER_ID                  :'||p_counter_template_rec.DERIVE_COUNTER_ID);
   PUT_LINE ('DERIVE_FUNCTION                    :'||p_counter_template_rec.DERIVE_FUNCTION);
   PUT_LINE ('DERIVE_PROPERTY_ID                 :'||p_counter_template_rec.DERIVE_PROPERTY_ID);
   PUT_LINE ('VALID_FLAG                         :'||p_counter_template_rec.VALID_FLAG);
   PUT_LINE ('FORMULA_INCOMPLETE_FLAG            :'||p_counter_template_rec.FORMULA_INCOMPLETE_FLAG);
   PUT_LINE ('FORMULA_TEXT                       :'||p_counter_template_rec.FORMULA_TEXT);
   PUT_LINE ('ROLLOVER_LAST_READING              :'||p_counter_template_rec.ROLLOVER_LAST_READING);
   PUT_LINE ('ROLLOVER_FIRST_READING             :'||p_counter_template_rec.ROLLOVER_FIRST_READING);
   PUT_LINE ('USAGE_ITEM_ID                      :'||p_counter_template_rec.USAGE_ITEM_ID);
   PUT_LINE ('CTR_VAL_MAX_SEQ_NO                 :'||p_counter_template_rec.CTR_VAL_MAX_SEQ_NO);
   PUT_LINE ('START_DATE_ACTIVE                  :'||p_counter_template_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE                    :'||p_counter_template_rec.END_DATE_ACTIVE);
   PUT_LINE ('OBJECT_VERSION_NUMBER              :'||p_counter_template_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                         :'||p_counter_template_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                         :'||p_counter_template_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                         :'||p_counter_template_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                         :'||p_counter_template_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                         :'||p_counter_template_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                         :'||p_counter_template_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                         :'||p_counter_template_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                         :'||p_counter_template_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                         :'||p_counter_template_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                        :'||p_counter_template_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                        :'||p_counter_template_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                        :'||p_counter_template_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                        :'||p_counter_template_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                        :'||p_counter_template_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                        :'||p_counter_template_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE16                        :'||p_counter_template_rec.ATTRIBUTE16);
   PUT_LINE ('ATTRIBUTE17                        :'||p_counter_template_rec.ATTRIBUTE17);
   PUT_LINE ('ATTRIBUTE18                        :'||p_counter_template_rec.ATTRIBUTE18);
   PUT_LINE ('ATTRIBUTE19                        :'||p_counter_template_rec.ATTRIBUTE19);
   PUT_LINE ('ATTRIBUTE20                        :'||p_counter_template_rec.ATTRIBUTE20);
   PUT_LINE ('ATTRIBUTE21                        :'||p_counter_template_rec.ATTRIBUTE21);
   PUT_LINE ('ATTRIBUTE22                        :'||p_counter_template_rec.ATTRIBUTE22);
   PUT_LINE ('ATTRIBUTE23                        :'||p_counter_template_rec.ATTRIBUTE23);
   PUT_LINE ('ATTRIBUTE24                        :'||p_counter_template_rec.ATTRIBUTE24);
   PUT_LINE ('ATTRIBUTE25                        :'||p_counter_template_rec.ATTRIBUTE25);
   PUT_LINE ('ATTRIBUTE26                        :'||p_counter_template_rec.ATTRIBUTE26);
   PUT_LINE ('ATTRIBUTE27                        :'||p_counter_template_rec.ATTRIBUTE27);
   PUT_LINE ('ATTRIBUTE28                        :'||p_counter_template_rec.ATTRIBUTE28);
   PUT_LINE ('ATTRIBUTE29                        :'||p_counter_template_rec.ATTRIBUTE29);
   PUT_LINE ('ATTRIBUTE30                        :'||p_counter_template_rec.ATTRIBUTE30);
   PUT_LINE ('ATTRIBUTE_CATEGORY                 :'||p_counter_template_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('DIRECTION                          :'||p_counter_template_rec.DIRECTION);
   PUT_LINE ('FILTER_TYPE                        :'||p_counter_template_rec.FILTER_TYPE);
   PUT_LINE ('FILTER_READING_COUNT               :'||p_counter_template_rec.FILTER_READING_COUNT);
   PUT_LINE ('FILTER_TIME_UOM                    :'||p_counter_template_rec.FILTER_TIME_UOM);
   PUT_LINE ('ESTIMATION_ID                      :'||p_counter_template_rec.ESTIMATION_ID);
   PUT_LINE ('READING_TYPE                       :'||p_counter_template_rec.READING_TYPE);
   PUT_LINE ('AUTOMATIC_ROLLOVER                 :'||p_counter_template_rec.AUTOMATIC_ROLLOVER);
   PUT_LINE ('DEFAULT_USAGE_RATE                 :'||p_counter_template_rec.DEFAULT_USAGE_RATE);
   PUT_LINE ('USE_PAST_READING                   :'||p_counter_template_rec.USE_PAST_READING);
   PUT_LINE ('USED_IN_SCHEDULING                 :'||p_counter_template_rec.USED_IN_SCHEDULING);
   PUT_LINE ('DEFAULTED_GROUP_ID                 :'||p_counter_template_rec.DEFAULTED_GROUP_ID);
   PUT_LINE ('SECURITY_GROUP_ID                  :'||p_counter_template_rec.SECURITY_GROUP_ID);
   PUT_LINE ('NAME                               :'||p_counter_template_rec.NAME);
   PUT_LINE ('DESCRIPTION                        :'||p_counter_template_rec.DESCRIPTION);
   PUT_LINE ('COMMENTS                           :'||p_counter_template_rec.COMMENTS);
   PUT_LINE ('ASSOCIATION_TYPE                   :'||p_counter_template_rec.ASSOCIATION_TYPE);
   PUT_LINE ('STEP_VALUE                         :'||p_counter_template_rec.STEP_VALUE);
   PUT_LINE ('TIME_BASED_MANUAL_ENTRY            :'||p_counter_template_rec.TIME_BASED_MANUAL_ENTRY);
   PUT_LINE ('EAM_REQUIRED_FLAG                  :'||p_counter_template_rec.EAM_REQUIRED_FLAG);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_template_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_template_rec;

PROCEDURE dump_ctr_template_tbl
   (p_counter_template_tbl IN  csi_ctr_datastructures_pub.counter_template_tbl) IS

   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_template_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_template_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_counter_template_tbl.COUNT > 0 THEN
      FOR tab_row IN p_counter_template_tbl.FIRST .. p_counter_template_tbl.LAST
      LOOP
         IF p_counter_template_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Template Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');
           PUT_LINE ('COUNTER_ID                         :'||p_counter_template_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('GROUP_ID                           :'||p_counter_template_tbl(tab_row).GROUP_ID);
	   PUT_LINE ('DESCRIPTION                        :'||p_counter_template_tbl(tab_row).DESCRIPTION);
	   PUT_LINE ('COUNTER_TYPE                       :'||p_counter_template_tbl(tab_row).COUNTER_TYPE);
	   PUT_LINE ('INITIAL_READING                    :'||p_counter_template_tbl(tab_row).INITIAL_READING);
	   PUT_LINE ('INITIAL_READING_DATE               :'||p_counter_template_tbl(tab_row).INITIAL_READING_DATE);
	   PUT_LINE ('TOLERANCE_PLUS                     :'||p_counter_template_tbl(tab_row).TOLERANCE_PLUS);
	   PUT_LINE ('TOLERANCE_MINUS                    :'||p_counter_template_tbl(tab_row).TOLERANCE_MINUS);
	   PUT_LINE ('UOM_CODE                           :'||p_counter_template_tbl(tab_row).UOM_CODE);
	   PUT_LINE ('DERIVE_COUNTER_ID                  :'||p_counter_template_tbl(tab_row).DERIVE_COUNTER_ID);
	   PUT_LINE ('DERIVE_FUNCTION                    :'||p_counter_template_tbl(tab_row).DERIVE_FUNCTION);
	   PUT_LINE ('DERIVE_PROPERTY_ID                 :'||p_counter_template_tbl(tab_row).DERIVE_PROPERTY_ID);
	   PUT_LINE ('VALID_FLAG                         :'||p_counter_template_tbl(tab_row).VALID_FLAG);
	   PUT_LINE ('FORMULA_INCOMPLETE_FLAG            :'||p_counter_template_tbl(tab_row).FORMULA_INCOMPLETE_FLAG);
	   PUT_LINE ('FORMULA_TEXT                       :'||p_counter_template_tbl(tab_row).FORMULA_TEXT);
	   PUT_LINE ('ROLLOVER_LAST_READING              :'||p_counter_template_tbl(tab_row).ROLLOVER_LAST_READING);
	   PUT_LINE ('ROLLOVER_FIRST_READING             :'||p_counter_template_tbl(tab_row).ROLLOVER_FIRST_READING);           	   PUT_LINE ('USAGE_ITEM_ID                      :'||p_counter_template_tbl(tab_row).USAGE_ITEM_ID);
	   PUT_LINE ('CTR_VAL_MAX_SEQ_NO                 :'||p_counter_template_tbl(tab_row).CTR_VAL_MAX_SEQ_NO);
	   PUT_LINE ('START_DATE_ACTIVE                  :'||p_counter_template_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE                    :'||p_counter_template_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER              :'||p_counter_template_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                         :'||p_counter_template_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE16                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE16);
	   PUT_LINE ('ATTRIBUTE17                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE17);
	   PUT_LINE ('ATTRIBUTE18                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE18);
	   PUT_LINE ('ATTRIBUTE19                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE19);
	   PUT_LINE ('ATTRIBUTE20                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE20);
	   PUT_LINE ('ATTRIBUTE21                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE21);
	   PUT_LINE ('ATTRIBUTE22                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE22);
	   PUT_LINE ('ATTRIBUTE23                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE23);
	   PUT_LINE ('ATTRIBUTE24                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE24);
	   PUT_LINE ('ATTRIBUTE25                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE25);
	   PUT_LINE ('ATTRIBUTE26                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE26);
	   PUT_LINE ('ATTRIBUTE27                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE27);
	   PUT_LINE ('ATTRIBUTE28                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE28);
	   PUT_LINE ('ATTRIBUTE29                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE29);
	   PUT_LINE ('ATTRIBUTE30                        :'||p_counter_template_tbl(tab_row).ATTRIBUTE30);
	   PUT_LINE ('ATTRIBUTE_CATEGORY                 :'||p_counter_template_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('DIRECTION                          :'||p_counter_template_tbl(tab_row).DIRECTION);
	   PUT_LINE ('FILTER_TYPE                        :'||p_counter_template_tbl(tab_row).FILTER_TYPE);
	   PUT_LINE ('FILTER_READING_COUNT               :'||p_counter_template_tbl(tab_row).FILTER_READING_COUNT);
	   PUT_LINE ('FILTER_TIME_UOM                    :'||p_counter_template_tbl(tab_row).FILTER_TIME_UOM);
	   PUT_LINE ('ESTIMATION_ID                      :'||p_counter_template_tbl(tab_row).ESTIMATION_ID);
	   PUT_LINE ('READING_TYPE                       :'||p_counter_template_tbl(tab_row).READING_TYPE);
	   PUT_LINE ('AUTOMATIC_ROLLOVER                 :'||p_counter_template_tbl(tab_row).AUTOMATIC_ROLLOVER);
	   PUT_LINE ('DEFAULT_USAGE_RATE                 :'||p_counter_template_tbl(tab_row).DEFAULT_USAGE_RATE);
	   PUT_LINE ('USE_PAST_READING                   :'||p_counter_template_tbl(tab_row).USE_PAST_READING);
	   PUT_LINE ('USED_IN_SCHEDULING                 :'||p_counter_template_tbl(tab_row).USED_IN_SCHEDULING);
	   PUT_LINE ('DEFAULTED_GROUP_ID                 :'||p_counter_template_tbl(tab_row).DEFAULTED_GROUP_ID);
           PUT_LINE ('SECURITY_GROUP_ID                  :'||p_counter_template_tbl(tab_row).SECURITY_GROUP_ID);
	   PUT_LINE ('NAME                               :'||p_counter_template_tbl(tab_row).NAME);
	   PUT_LINE ('DESCRIPTION                        :'||p_counter_template_tbl(tab_row).DESCRIPTION);
	   PUT_LINE ('COMMENTS                           :'||p_counter_template_tbl(tab_row).COMMENTS);
	   PUT_LINE ('ASSOCIATION_TYPE                   :'||p_counter_template_tbl(tab_row).ASSOCIATION_TYPE);
	   PUT_LINE ('STEP_VALUE                         :'||p_counter_template_tbl(tab_row).STEP_VALUE);
	   PUT_LINE ('TIME_BASED_MANUAL_ENTRY            :'||p_counter_template_tbl(tab_row).TIME_BASED_MANUAL_ENTRY);
	   PUT_LINE ('EAM_REQUIRED_FLAG                  :'||p_counter_template_tbl(tab_row).EAM_REQUIRED_FLAG);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_template_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_template_tbl;


PROCEDURE dump_ctr_item_assoc_rec
   (p_ctr_item_associations_rec IN  csi_ctr_datastructures_pub.ctr_item_associations_rec) IS

   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_item_assoc_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dump_ctr_item_assoc_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Item Association Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('CTR_ASSOCIATION_ID        :'||p_ctr_item_associations_rec.CTR_ASSOCIATION_ID);
   PUT_LINE ('GROUP_ID                  :'||p_ctr_item_associations_rec.GROUP_ID);
   PUT_LINE ('INVENTORY_ITEM_ID         :'||p_ctr_item_associations_rec.INVENTORY_ITEM_ID);
   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_item_associations_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                :'||p_ctr_item_associations_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                :'||p_ctr_item_associations_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                :'||p_ctr_item_associations_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                :'||p_ctr_item_associations_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                :'||p_ctr_item_associations_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                :'||p_ctr_item_associations_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                :'||p_ctr_item_associations_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                :'||p_ctr_item_associations_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                :'||p_ctr_item_associations_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10               :'||p_ctr_item_associations_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11               :'||p_ctr_item_associations_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12               :'||p_ctr_item_associations_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13               :'||p_ctr_item_associations_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14               :'||p_ctr_item_associations_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15               :'||p_ctr_item_associations_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_ctr_item_associations_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('SECURITY_GROUP_ID         :'||p_ctr_item_associations_rec.SECURITY_GROUP_ID);
   PUT_LINE ('COUNTER_ID                :'||p_ctr_item_associations_rec.COUNTER_ID);
   PUT_LINE ('START_DATE_ACTIVE         :'||p_ctr_item_associations_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE           :'||p_ctr_item_associations_rec.END_DATE_ACTIVE);
   PUT_LINE ('USAGE_RATE                :'||p_ctr_item_associations_rec.USAGE_RATE);
   -- PUT_LINE ('ASSOCIATION_TYPE          :'||p_ctr_item_associations_rec.ASSOCIATION_TYPE);
   PUT_LINE ('USE_PAST_READING          :'||p_ctr_item_associations_rec.USE_PAST_READING);
   PUT_LINE ('ASSOCIATED_TO_GROUP       :'||p_ctr_item_associations_rec.ASSOCIATED_TO_GROUP);
   PUT_LINE ('MAINT_ORGANIZATION_ID     :'||p_ctr_item_associations_rec.MAINT_ORGANIZATION_ID);
   PUT_LINE ('PRIMARY_FAILURE_FLAG      :'||p_ctr_item_associations_rec.PRIMARY_FAILURE_FLAG);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_item_assoc_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_item_assoc_rec;

PROCEDURE dump_ctr_item_assoc_tbl
   (p_ctr_item_associations_tbl IN  csi_ctr_datastructures_pub.ctr_item_associations_tbl) IS


   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_item_assoc_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
   SAVEPOINT dump_ctr_item_assoc_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_item_associations_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_item_associations_tbl.FIRST .. p_ctr_item_associations_tbl.LAST
      LOOP
         IF p_ctr_item_associations_tbl.EXISTS(tab_row) THEN

  	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Item Association Table Record # : '||tab_row);
           PUT_LINE ('                                       ');

	   PUT_LINE ('CTR_ASSOCIATION_ID        :'||p_ctr_item_associations_tbl(tab_row).CTR_ASSOCIATION_ID);
	   PUT_LINE ('GROUP_ID                  :'||p_ctr_item_associations_tbl(tab_row).GROUP_ID);
	   PUT_LINE ('INVENTORY_ITEM_ID         :'||p_ctr_item_associations_tbl(tab_row).INVENTORY_ITEM_ID);
	   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_item_associations_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10               :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11               :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12               :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13               :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14               :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15               :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_ctr_item_associations_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('SECURITY_GROUP_ID         :'||p_ctr_item_associations_tbl(tab_row).SECURITY_GROUP_ID);
	   PUT_LINE ('COUNTER_ID                :'||p_ctr_item_associations_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('START_DATE_ACTIVE         :'||p_ctr_item_associations_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE           :'||p_ctr_item_associations_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('USAGE_RATE                :'||p_ctr_item_associations_tbl(tab_row).USAGE_RATE);
--	   PUT_LINE ('ASSOCIATION_TYPE          :'||p_ctr_item_associations_tbl(tab_row).ASSOCIATION_TYPE);
	   PUT_LINE ('USE_PAST_READING          :'||p_ctr_item_associations_tbl(tab_row).USE_PAST_READING);
	   PUT_LINE ('ASSOCIATED_TO_GROUP       :'||p_ctr_item_associations_tbl(tab_row).ASSOCIATED_TO_GROUP);
	   PUT_LINE ('MAINT_ORGANIZATION_ID     :'||p_ctr_item_associations_tbl(tab_row).MAINT_ORGANIZATION_ID);
	   PUT_LINE ('PRIMARY_FAILURE_FLAG      :'||p_ctr_item_associations_tbl(tab_row).PRIMARY_FAILURE_FLAG);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_item_assoc_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_item_assoc_tbl;

PROCEDURE dump_ctr_relationship_rec
   (p_counter_relationships_rec IN  csi_ctr_datastructures_pub.counter_relationships_rec) IS

   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_relationship_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
  SAVEPOINT  dump_ctr_relationship_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Relationships Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('RELATIONSHIP_ID           :'||p_counter_relationships_rec.RELATIONSHIP_ID);
   PUT_LINE ('CTR_ASSOCIATION_ID        :'||p_counter_relationships_rec.CTR_ASSOCIATION_ID);
   PUT_LINE ('RELATIONSHIP_TYPE_CODE    :'||p_counter_relationships_rec.RELATIONSHIP_TYPE_CODE);
   PUT_LINE ('SOURCE_COUNTER_ID         :'||p_counter_relationships_rec.SOURCE_COUNTER_ID);
   PUT_LINE ('OBJECT_COUNTER_ID         :'||p_counter_relationships_rec.OBJECT_COUNTER_ID);
   PUT_LINE ('ACTIVE_START_DATE         :'||p_counter_relationships_rec.ACTIVE_START_DATE);
   PUT_LINE ('ACTIVE_END_DATE           :'||p_counter_relationships_rec.ACTIVE_END_DATE);
   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_counter_relationships_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_counter_relationships_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('ATTRIBUTE1                :'||p_counter_relationships_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                :'||p_counter_relationships_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                :'||p_counter_relationships_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                :'||p_counter_relationships_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                :'||p_counter_relationships_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                :'||p_counter_relationships_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                :'||p_counter_relationships_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                :'||p_counter_relationships_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                :'||p_counter_relationships_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10               :'||p_counter_relationships_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11               :'||p_counter_relationships_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12               :'||p_counter_relationships_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13               :'||p_counter_relationships_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14               :'||p_counter_relationships_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15               :'||p_counter_relationships_rec.ATTRIBUTE15);
   PUT_LINE ('SECURITY_GROUP_ID         :'||p_counter_relationships_rec.SECURITY_GROUP_ID);
   PUT_LINE ('BIND_VARIABLE_NAME        :'||p_counter_relationships_rec.BIND_VARIABLE_NAME);
   PUT_LINE ('FACTOR                    :'||p_counter_relationships_rec.FACTOR);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_relationship_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_relationship_rec;

PROCEDURE dump_ctr_relationship_tbl
   (p_counter_relationships_tbl IN  csi_ctr_datastructures_pub.counter_relationships_tbl) IS


   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_relationship_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_relationship_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_counter_relationships_tbl.COUNT > 0 THEN
      FOR tab_row IN p_counter_relationships_tbl.FIRST .. p_counter_relationships_tbl.LAST
      LOOP
         IF p_counter_relationships_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Relationship Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('RELATIONSHIP_ID           :'||p_counter_relationships_tbl(tab_row).RELATIONSHIP_ID);
	   PUT_LINE ('CTR_ASSOCIATION_ID        :'||p_counter_relationships_tbl(tab_row).CTR_ASSOCIATION_ID);
	   PUT_LINE ('RELATIONSHIP_TYPE_CODE    :'||p_counter_relationships_tbl(tab_row).RELATIONSHIP_TYPE_CODE);
	   PUT_LINE ('SOURCE_COUNTER_ID         :'||p_counter_relationships_tbl(tab_row).SOURCE_COUNTER_ID);
	   PUT_LINE ('OBJECT_COUNTER_ID         :'||p_counter_relationships_tbl(tab_row).OBJECT_COUNTER_ID);
	   PUT_LINE ('ACTIVE_START_DATE         :'||p_counter_relationships_tbl(tab_row).ACTIVE_START_DATE);
	   PUT_LINE ('ACTIVE_END_DATE           :'||p_counter_relationships_tbl(tab_row).ACTIVE_END_DATE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_counter_relationships_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('ATTRIBUTE1                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10               :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11               :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12               :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13               :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14               :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15               :'||p_counter_relationships_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('SECURITY_GROUP_ID         :'||p_counter_relationships_tbl(tab_row).SECURITY_GROUP_ID);
	   PUT_LINE ('BIND_VARIABLE_NAME        :'||p_counter_relationships_tbl(tab_row).BIND_VARIABLE_NAME);
	   PUT_LINE ('FACTOR                    :'||p_counter_relationships_tbl(tab_row).FACTOR);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_relationship_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_relationship_tbl;

PROCEDURE dump_ctr_property_template_rec
   (p_ctr_property_template_rec IN  csi_ctr_datastructures_pub.ctr_property_template_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_property_template_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
  SAVEPOINT  dump_ctr_property_template_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Property Template Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_PROPERTY_ID      :'||p_ctr_property_template_rec.COUNTER_PROPERTY_ID);
   PUT_LINE ('COUNTER_ID               :'||p_ctr_property_template_rec.COUNTER_ID);
   PUT_LINE ('PROPERTY_DATA_TYPE       :'||p_ctr_property_template_rec.PROPERTY_DATA_TYPE);
   PUT_LINE ('IS_NULLABLE              :'||p_ctr_property_template_rec.IS_NULLABLE);
   PUT_LINE ('DEFAULT_VALUE            :'||p_ctr_property_template_rec.DEFAULT_VALUE);
   PUT_LINE ('MINIMUM_VALUE            :'||p_ctr_property_template_rec.MINIMUM_VALUE);
   PUT_LINE ('MAXIMUM_VALUE            :'||p_ctr_property_template_rec.MAXIMUM_VALUE);
   PUT_LINE ('UOM_CODE                 :'||p_ctr_property_template_rec.UOM_CODE);
   PUT_LINE ('START_DATE_ACTIVE        :'||p_ctr_property_template_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE          :'||p_ctr_property_template_rec.END_DATE_ACTIVE);
   PUT_LINE ('OBJECT_VERSION_NUMBER    :'||p_ctr_property_template_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1               :'||p_ctr_property_template_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2               :'||p_ctr_property_template_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3               :'||p_ctr_property_template_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4               :'||p_ctr_property_template_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5               :'||p_ctr_property_template_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6               :'||p_ctr_property_template_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7               :'||p_ctr_property_template_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8               :'||p_ctr_property_template_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9               :'||p_ctr_property_template_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10              :'||p_ctr_property_template_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11              :'||p_ctr_property_template_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12              :'||p_ctr_property_template_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13              :'||p_ctr_property_template_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14              :'||p_ctr_property_template_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15              :'||p_ctr_property_template_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY       :'||p_ctr_property_template_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('PROPERTY_LOV_TYPE        :'||p_ctr_property_template_rec.PROPERTY_LOV_TYPE);
   PUT_LINE ('SECURITY_GROUP_ID        :'||p_ctr_property_template_rec.SECURITY_GROUP_ID);
   PUT_LINE ('NAME                     :'||p_ctr_property_template_rec.NAME);
   PUT_LINE ('DESCRIPTION              :'||p_ctr_property_template_rec.DESCRIPTION);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_property_template_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_property_template_rec;

PROCEDURE dump_ctr_property_template_tbl
   (p_ctr_property_template_tbl IN  csi_ctr_datastructures_pub.ctr_property_template_tbl) IS

   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_property_template_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_property_template_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_property_template_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_property_template_tbl.FIRST .. p_ctr_property_template_tbl.LAST
      LOOP
         IF p_ctr_property_template_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Property Template Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_PROPERTY_ID      :'||p_ctr_property_template_tbl(tab_row).COUNTER_PROPERTY_ID);
	   PUT_LINE ('COUNTER_ID               :'||p_ctr_property_template_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('PROPERTY_DATA_TYPE       :'||p_ctr_property_template_tbl(tab_row).PROPERTY_DATA_TYPE);
	   PUT_LINE ('IS_NULLABLE              :'||p_ctr_property_template_tbl(tab_row).IS_NULLABLE);
	   PUT_LINE ('DEFAULT_VALUE            :'||p_ctr_property_template_tbl(tab_row).DEFAULT_VALUE);
	   PUT_LINE ('MINIMUM_VALUE            :'||p_ctr_property_template_tbl(tab_row).MINIMUM_VALUE);
	   PUT_LINE ('MAXIMUM_VALUE            :'||p_ctr_property_template_tbl(tab_row).MAXIMUM_VALUE);
	   PUT_LINE ('UOM_CODE                 :'||p_ctr_property_template_tbl(tab_row).UOM_CODE);
	   PUT_LINE ('START_DATE_ACTIVE        :'||p_ctr_property_template_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE          :'||p_ctr_property_template_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER    :'||p_ctr_property_template_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9               :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10              :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11              :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12              :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13              :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14              :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15              :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY       :'||p_ctr_property_template_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('PROPERTY_LOV_TYPE        :'||p_ctr_property_template_tbl(tab_row).PROPERTY_LOV_TYPE);
           PUT_LINE ('SECURITY_GROUP_ID        :'||p_ctr_property_template_tbl(tab_row).SECURITY_GROUP_ID);
	   PUT_LINE ('NAME                     :'||p_ctr_property_template_tbl(tab_row).NAME);
	   PUT_LINE ('DESCRIPTION              :'||p_ctr_property_template_tbl(tab_row).DESCRIPTION);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_property_template_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_property_template_tbl;

PROCEDURE dm_ctr_estimation_methods_rec
   (p_ctr_estimation_methods_rec IN  csi_ctr_datastructures_pub.ctr_estimation_methods_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_estimation_methods_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dm_ctr_estimation_methods_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Estimation Methods Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('ESTIMATION_ID              :'||p_ctr_estimation_methods_rec.ESTIMATION_ID);
   PUT_LINE ('ESTIMATION_TYPE            :'||p_ctr_estimation_methods_rec.ESTIMATION_TYPE);
   PUT_LINE ('FIXED_VALUE                :'||p_ctr_estimation_methods_rec.FIXED_VALUE);
   PUT_LINE ('USAGE_MARKUP               :'||p_ctr_estimation_methods_rec.USAGE_MARKUP);
   PUT_LINE ('DEFAULT_VALUE              :'||p_ctr_estimation_methods_rec.DEFAULT_VALUE);
   PUT_LINE ('ESTIMATION_AVG_TYPE        :'||p_ctr_estimation_methods_rec.ESTIMATION_AVG_TYPE);
   PUT_LINE ('START_DATE_ACTIVE          :'||p_ctr_estimation_methods_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE            :'||p_ctr_estimation_methods_rec.END_DATE_ACTIVE);
   PUT_LINE ('ATTRIBUTE1                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                 :'||p_ctr_estimation_methods_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                :'||p_ctr_estimation_methods_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                :'||p_ctr_estimation_methods_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                :'||p_ctr_estimation_methods_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                :'||p_ctr_estimation_methods_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                :'||p_ctr_estimation_methods_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                :'||p_ctr_estimation_methods_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY         :'||p_ctr_estimation_methods_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('OBJECT_VERSION_NUMBER      :'||p_ctr_estimation_methods_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('NAME                       :'||p_ctr_estimation_methods_rec.NAME);
   PUT_LINE ('DESCRIPTION                :'||p_ctr_estimation_methods_rec.DESCRIPTION);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_estimation_methods_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dm_ctr_estimation_methods_rec;

PROCEDURE dm_ctr_estimation_methods_tbl
   (p_ctr_estimation_methods_tbl IN  csi_ctr_datastructures_pub.ctr_estimation_methods_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_estimation_methods_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dm_ctr_estimation_methods_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_estimation_methods_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_estimation_methods_tbl.FIRST .. p_ctr_estimation_methods_tbl.LAST
      LOOP
         IF p_ctr_estimation_methods_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Estimation Methods Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('ESTIMATION_ID              :'||p_ctr_estimation_methods_tbl(tab_row).ESTIMATION_ID);
	   PUT_LINE ('ESTIMATION_TYPE            :'||p_ctr_estimation_methods_tbl(tab_row).ESTIMATION_TYPE);
	   PUT_LINE ('FIXED_VALUE                :'||p_ctr_estimation_methods_tbl(tab_row).FIXED_VALUE);
	   PUT_LINE ('USAGE_MARKUP               :'||p_ctr_estimation_methods_tbl(tab_row).USAGE_MARKUP);
	   PUT_LINE ('DEFAULT_VALUE              :'||p_ctr_estimation_methods_tbl(tab_row).DEFAULT_VALUE);
	   PUT_LINE ('ESTIMATION_AVG_TYPE        :'||p_ctr_estimation_methods_tbl(tab_row).ESTIMATION_AVG_TYPE);
	   PUT_LINE ('START_DATE_ACTIVE          :'||p_ctr_estimation_methods_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE            :'||p_ctr_estimation_methods_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('ATTRIBUTE1                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                 :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY         :'||p_ctr_estimation_methods_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('OBJECT_VERSION_NUMBER      :'||p_ctr_estimation_methods_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('NAME                       :'||p_ctr_estimation_methods_tbl(tab_row).NAME);
	   PUT_LINE ('DESCRIPTION                :'||p_ctr_estimation_methods_tbl(tab_row).DESCRIPTION);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_estimation_methods_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dm_ctr_estimation_methods_tbl;

PROCEDURE dump_ctr_derived_filters_rec
   (p_ctr_derived_filters_rec IN  csi_ctr_datastructures_pub.ctr_derived_filters_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_derived_filters_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT  dump_ctr_derived_filters_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Derived Filters Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_DERIVED_FILTER_ID   :'||p_ctr_derived_filters_rec.COUNTER_DERIVED_FILTER_ID);
   PUT_LINE ('COUNTER_ID                  :'||p_ctr_derived_filters_rec.COUNTER_ID);
   PUT_LINE ('SEQ_NO                      :'||p_ctr_derived_filters_rec.SEQ_NO);
   PUT_LINE ('LEFT_PARENT                 :'||p_ctr_derived_filters_rec.LEFT_PARENT);
   PUT_LINE ('COUNTER_PROPERTY_ID         :'||p_ctr_derived_filters_rec.COUNTER_PROPERTY_ID);
   PUT_LINE ('RELATIONAL_OPERATOR         :'||p_ctr_derived_filters_rec.RELATIONAL_OPERATOR);
   PUT_LINE ('RIGHT_VALUE                 :'||p_ctr_derived_filters_rec.RIGHT_VALUE);
   PUT_LINE ('RIGHT_PARENT                :'||p_ctr_derived_filters_rec.RIGHT_PARENT);
   PUT_LINE ('LOGICAL_OPERATOR            :'||p_ctr_derived_filters_rec.LOGICAL_OPERATOR );
   PUT_LINE ('START_DATE_ACTIVE           :'||p_ctr_derived_filters_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE             :'||p_ctr_derived_filters_rec.END_DATE_ACTIVE);
   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_derived_filters_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_derived_filters_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_derived_filters_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_derived_filters_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_derived_filters_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_derived_filters_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_derived_filters_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_derived_filters_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_derived_filters_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_derived_filters_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_derived_filters_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_derived_filters_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_derived_filters_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_derived_filters_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_derived_filters_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_derived_filters_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_derived_filters_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('SECURITY_GROUP_ID           :'||p_ctr_derived_filters_rec.SECURITY_GROUP_ID);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_derived_filters_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_derived_filters_rec;

PROCEDURE dump_ctr_derived_filters_tbl
   (p_ctr_derived_filters_tbl IN  csi_ctr_datastructures_pub.ctr_derived_filters_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_derived_filters_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_derived_filters_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_derived_filters_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_derived_filters_tbl.FIRST .. p_ctr_derived_filters_tbl.LAST
      LOOP
         IF p_ctr_derived_filters_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Derived Filters Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_DERIVED_FILTER_ID   :'||p_ctr_derived_filters_tbl(tab_row).COUNTER_DERIVED_FILTER_ID);
	   PUT_LINE ('COUNTER_ID                  :'||p_ctr_derived_filters_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('SEQ_NO                      :'||p_ctr_derived_filters_tbl(tab_row).SEQ_NO);
	   PUT_LINE ('LEFT_PARENT                 :'||p_ctr_derived_filters_tbl(tab_row).LEFT_PARENT);
	   PUT_LINE ('COUNTER_PROPERTY_ID         :'||p_ctr_derived_filters_tbl(tab_row).COUNTER_PROPERTY_ID);
	   PUT_LINE ('RELATIONAL_OPERATOR         :'||p_ctr_derived_filters_tbl(tab_row).RELATIONAL_OPERATOR);
	   PUT_LINE ('RIGHT_VALUE                 :'||p_ctr_derived_filters_tbl(tab_row).RIGHT_VALUE);
	   PUT_LINE ('RIGHT_PARENT                :'||p_ctr_derived_filters_tbl(tab_row).RIGHT_PARENT);
	   PUT_LINE ('LOGICAL_OPERATOR            :'||p_ctr_derived_filters_tbl(tab_row).LOGICAL_OPERATOR );
	   PUT_LINE ('START_DATE_ACTIVE           :'||p_ctr_derived_filters_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE             :'||p_ctr_derived_filters_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_derived_filters_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_derived_filters_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('SECURITY_GROUP_ID           :'||p_ctr_derived_filters_tbl(tab_row).SECURITY_GROUP_ID);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_derived_filters_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_derived_filters_tbl;

PROCEDURE dump_counter_instance_rec
   (p_counter_instance_rec IN  csi_ctr_datastructures_pub.counter_instance_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_counter_instance_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dump_counter_instance_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Instance Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_ID                         :'||p_counter_instance_rec.COUNTER_ID);
   PUT_LINE ('GROUP_ID                           :'||p_counter_instance_rec.GROUP_ID);
   PUT_LINE ('DESCRIPTION                        :'||p_counter_instance_rec.DESCRIPTION);
   PUT_LINE ('COUNTER_TYPE                       :'||p_counter_instance_rec.COUNTER_TYPE);
   PUT_LINE ('INITIAL_READING                    :'||p_counter_instance_rec.INITIAL_READING);
   PUT_LINE ('INITIAL_READING_DATE               :'||p_counter_instance_rec.INITIAL_READING_DATE);
   PUT_LINE ('TOLERANCE_PLUS                     :'||p_counter_instance_rec.TOLERANCE_PLUS);
   PUT_LINE ('TOLERANCE_MINUS                    :'||p_counter_instance_rec.TOLERANCE_MINUS);
   PUT_LINE ('UOM_CODE                           :'||p_counter_instance_rec.UOM_CODE);
   PUT_LINE ('DERIVE_COUNTER_ID                  :'||p_counter_instance_rec.DERIVE_COUNTER_ID);
   PUT_LINE ('DERIVE_FUNCTION                    :'||p_counter_instance_rec.DERIVE_FUNCTION);
   PUT_LINE ('DERIVE_PROPERTY_ID                 :'||p_counter_instance_rec.DERIVE_PROPERTY_ID);
   PUT_LINE ('VALID_FLAG                         :'||p_counter_instance_rec.VALID_FLAG);
   PUT_LINE ('FORMULA_INCOMPLETE_FLAG            :'||p_counter_instance_rec.FORMULA_INCOMPLETE_FLAG);
   PUT_LINE ('FORMULA_TEXT                       :'||p_counter_instance_rec.FORMULA_TEXT);
   PUT_LINE ('ROLLOVER_LAST_READING              :'||p_counter_instance_rec.ROLLOVER_LAST_READING);
   PUT_LINE ('ROLLOVER_FIRST_READING             :'||p_counter_instance_rec.ROLLOVER_FIRST_READING);
   PUT_LINE ('USAGE_ITEM_ID                      :'||p_counter_instance_rec.USAGE_ITEM_ID);
   PUT_LINE ('CTR_VAL_MAX_SEQ_NO                 :'||p_counter_instance_rec.CTR_VAL_MAX_SEQ_NO);
   PUT_LINE ('START_DATE_ACTIVE                  :'||p_counter_instance_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE                    :'||p_counter_instance_rec.END_DATE_ACTIVE);
   PUT_LINE ('OBJECT_VERSION_NUMBER              :'||p_counter_instance_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                         :'||p_counter_instance_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                         :'||p_counter_instance_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                         :'||p_counter_instance_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                         :'||p_counter_instance_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                         :'||p_counter_instance_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                         :'||p_counter_instance_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                         :'||p_counter_instance_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                         :'||p_counter_instance_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                         :'||p_counter_instance_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                        :'||p_counter_instance_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                        :'||p_counter_instance_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                        :'||p_counter_instance_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                        :'||p_counter_instance_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                        :'||p_counter_instance_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                        :'||p_counter_instance_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE16                        :'||p_counter_instance_rec.ATTRIBUTE16);
   PUT_LINE ('ATTRIBUTE17                        :'||p_counter_instance_rec.ATTRIBUTE17);
   PUT_LINE ('ATTRIBUTE18                        :'||p_counter_instance_rec.ATTRIBUTE18);
   PUT_LINE ('ATTRIBUTE19                        :'||p_counter_instance_rec.ATTRIBUTE19);
   PUT_LINE ('ATTRIBUTE20                        :'||p_counter_instance_rec.ATTRIBUTE20);
   PUT_LINE ('ATTRIBUTE21                        :'||p_counter_instance_rec.ATTRIBUTE21);
   PUT_LINE ('ATTRIBUTE22                        :'||p_counter_instance_rec.ATTRIBUTE22);
   PUT_LINE ('ATTRIBUTE23                        :'||p_counter_instance_rec.ATTRIBUTE23);
   PUT_LINE ('ATTRIBUTE24                        :'||p_counter_instance_rec.ATTRIBUTE24);
   PUT_LINE ('ATTRIBUTE25                        :'||p_counter_instance_rec.ATTRIBUTE25);
   PUT_LINE ('ATTRIBUTE26                        :'||p_counter_instance_rec.ATTRIBUTE26);
   PUT_LINE ('ATTRIBUTE27                        :'||p_counter_instance_rec.ATTRIBUTE27);
   PUT_LINE ('ATTRIBUTE28                        :'||p_counter_instance_rec.ATTRIBUTE28);
   PUT_LINE ('ATTRIBUTE29                        :'||p_counter_instance_rec.ATTRIBUTE29);
   PUT_LINE ('ATTRIBUTE30                        :'||p_counter_instance_rec.ATTRIBUTE30);
   PUT_LINE ('ATTRIBUTE_CATEGORY                 :'||p_counter_instance_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('DIRECTION                          :'||p_counter_instance_rec.DIRECTION);
   PUT_LINE ('FILTER_TYPE                        :'||p_counter_instance_rec.FILTER_TYPE);
   PUT_LINE ('FILTER_READING_COUNT               :'||p_counter_instance_rec.FILTER_READING_COUNT);
   PUT_LINE ('FILTER_TIME_UOM                    :'||p_counter_instance_rec.FILTER_TIME_UOM);
   PUT_LINE ('ESTIMATION_ID                      :'||p_counter_instance_rec.ESTIMATION_ID);
   PUT_LINE ('READING_TYPE                       :'||p_counter_instance_rec.READING_TYPE);
   PUT_LINE ('AUTOMATIC_ROLLOVER                 :'||p_counter_instance_rec.AUTOMATIC_ROLLOVER);
   PUT_LINE ('DEFAULT_USAGE_RATE                 :'||p_counter_instance_rec.DEFAULT_USAGE_RATE);
   PUT_LINE ('USE_PAST_READING                   :'||p_counter_instance_rec.USE_PAST_READING);
   PUT_LINE ('USED_IN_SCHEDULING                 :'||p_counter_instance_rec.USED_IN_SCHEDULING);
   PUT_LINE ('DEFAULTED_GROUP_ID                 :'||p_counter_instance_rec.DEFAULTED_GROUP_ID);
   PUT_LINE ('SECURITY_GROUP_ID                  :'||p_counter_instance_rec.SECURITY_GROUP_ID);
   PUT_LINE ('CREATED_FROM_COUNTER_TMPL_ID       :'||p_counter_instance_rec.CREATED_FROM_COUNTER_TMPL_ID);
   PUT_LINE ('NAME                               :'||p_counter_instance_rec.NAME);
   PUT_LINE ('DESCRIPTION                        :'||p_counter_instance_rec.DESCRIPTION);
   PUT_LINE ('COMMENTS                           :'||p_counter_instance_rec.COMMENTS);
   PUT_LINE ('STEP_VALUE                         :'||p_counter_instance_rec.STEP_VALUE);
   PUT_LINE ('TIME_BASED_MANUAL_ENTRY            :'||p_counter_instance_rec.TIME_BASED_MANUAL_ENTRY);
   PUT_LINE ('EAM_REQUIRED_FLAG                  :'||p_counter_instance_rec.EAM_REQUIRED_FLAG);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_counter_instance_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_counter_instance_rec;

PROCEDURE dump_counter_instance_tbl
   (p_counter_instance_tbl IN  csi_ctr_datastructures_pub.counter_instance_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_counter_instance_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_counter_instance_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_counter_instance_tbl.COUNT > 0 THEN
      FOR tab_row IN p_counter_instance_tbl.FIRST .. p_counter_instance_tbl.LAST
      LOOP
         IF p_counter_instance_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Instance Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');
           PUT_LINE ('COUNTER_ID                         :'||p_counter_instance_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('GROUP_ID                           :'||p_counter_instance_tbl(tab_row).GROUP_ID);
	   PUT_LINE ('DESCRIPTION                        :'||p_counter_instance_tbl(tab_row).DESCRIPTION);
	   PUT_LINE ('COUNTER_TYPE                       :'||p_counter_instance_tbl(tab_row).COUNTER_TYPE);
	   PUT_LINE ('INITIAL_READING                    :'||p_counter_instance_tbl(tab_row).INITIAL_READING);
	   PUT_LINE ('INITIAL_READING_DATE               :'||p_counter_instance_tbl(tab_row).INITIAL_READING_DATE);
	   PUT_LINE ('TOLERANCE_PLUS                     :'||p_counter_instance_tbl(tab_row).TOLERANCE_PLUS);
	   PUT_LINE ('TOLERANCE_MINUS                    :'||p_counter_instance_tbl(tab_row).TOLERANCE_MINUS);
	   PUT_LINE ('UOM_CODE                           :'||p_counter_instance_tbl(tab_row).UOM_CODE);
	   PUT_LINE ('DERIVE_COUNTER_ID                  :'||p_counter_instance_tbl(tab_row).DERIVE_COUNTER_ID);
	   PUT_LINE ('DERIVE_FUNCTION                    :'||p_counter_instance_tbl(tab_row).DERIVE_FUNCTION);
	   PUT_LINE ('DERIVE_PROPERTY_ID                 :'||p_counter_instance_tbl(tab_row).DERIVE_PROPERTY_ID);
	   PUT_LINE ('VALID_FLAG                         :'||p_counter_instance_tbl(tab_row).VALID_FLAG);
	   PUT_LINE ('FORMULA_INCOMPLETE_FLAG            :'||p_counter_instance_tbl(tab_row).FORMULA_INCOMPLETE_FLAG);
	   PUT_LINE ('FORMULA_TEXT                       :'||p_counter_instance_tbl(tab_row).FORMULA_TEXT);
	   PUT_LINE ('ROLLOVER_LAST_READING              :'||p_counter_instance_tbl(tab_row).ROLLOVER_LAST_READING);
	   PUT_LINE ('ROLLOVER_FIRST_READING             :'||p_counter_instance_tbl(tab_row).ROLLOVER_FIRST_READING);           	   PUT_LINE ('USAGE_ITEM_ID                      :'||p_counter_instance_tbl(tab_row).USAGE_ITEM_ID);
	   PUT_LINE ('CTR_VAL_MAX_SEQ_NO                 :'||p_counter_instance_tbl(tab_row).CTR_VAL_MAX_SEQ_NO);
	   PUT_LINE ('START_DATE_ACTIVE                  :'||p_counter_instance_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE                    :'||p_counter_instance_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER              :'||p_counter_instance_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                         :'||p_counter_instance_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE16                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE16);
	   PUT_LINE ('ATTRIBUTE17                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE17);
	   PUT_LINE ('ATTRIBUTE18                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE18);
	   PUT_LINE ('ATTRIBUTE19                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE19);
	   PUT_LINE ('ATTRIBUTE20                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE20);
	   PUT_LINE ('ATTRIBUTE21                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE21);
	   PUT_LINE ('ATTRIBUTE22                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE22);
	   PUT_LINE ('ATTRIBUTE23                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE23);
	   PUT_LINE ('ATTRIBUTE24                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE24);
	   PUT_LINE ('ATTRIBUTE25                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE25);
	   PUT_LINE ('ATTRIBUTE26                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE26);
	   PUT_LINE ('ATTRIBUTE27                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE27);
	   PUT_LINE ('ATTRIBUTE28                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE28);
	   PUT_LINE ('ATTRIBUTE29                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE29);
	   PUT_LINE ('ATTRIBUTE30                        :'||p_counter_instance_tbl(tab_row).ATTRIBUTE30);
	   PUT_LINE ('ATTRIBUTE_CATEGORY                 :'||p_counter_instance_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('DIRECTION                          :'||p_counter_instance_tbl(tab_row).DIRECTION);
	   PUT_LINE ('FILTER_TYPE                        :'||p_counter_instance_tbl(tab_row).FILTER_TYPE);
	   PUT_LINE ('FILTER_READING_COUNT               :'||p_counter_instance_tbl(tab_row).FILTER_READING_COUNT);
	   PUT_LINE ('FILTER_TIME_UOM                    :'||p_counter_instance_tbl(tab_row).FILTER_TIME_UOM);
	   PUT_LINE ('ESTIMATION_ID                      :'||p_counter_instance_tbl(tab_row).ESTIMATION_ID);
	   PUT_LINE ('READING_TYPE                       :'||p_counter_instance_tbl(tab_row).READING_TYPE);
	   PUT_LINE ('AUTOMATIC_ROLLOVER                 :'||p_counter_instance_tbl(tab_row).AUTOMATIC_ROLLOVER);
	   PUT_LINE ('DEFAULT_USAGE_RATE                 :'||p_counter_instance_tbl(tab_row).DEFAULT_USAGE_RATE);
	   PUT_LINE ('USE_PAST_READING                   :'||p_counter_instance_tbl(tab_row).USE_PAST_READING);
	   PUT_LINE ('USED_IN_SCHEDULING                 :'||p_counter_instance_tbl(tab_row).USED_IN_SCHEDULING);
	   PUT_LINE ('DEFAULTED_GROUP_ID                 :'||p_counter_instance_tbl(tab_row).DEFAULTED_GROUP_ID);
           PUT_LINE ('SECURITY_GROUP_ID                  :'||p_counter_instance_tbl(tab_row).SECURITY_GROUP_ID);
           PUT_LINE ('CREATED_FROM_COUNTER_TMPL_ID       :'||p_counter_instance_tbl(tab_row).CREATED_FROM_COUNTER_TMPL_ID);
	   PUT_LINE ('NAME                               :'||p_counter_instance_tbl(tab_row).NAME);
	   PUT_LINE ('DESCRIPTION                        :'||p_counter_instance_tbl(tab_row).DESCRIPTION);
	   PUT_LINE ('COMMENTS                           :'||p_counter_instance_tbl(tab_row).COMMENTS);
	   PUT_LINE ('STEP_VALUE                         :'||p_counter_instance_tbl(tab_row).STEP_VALUE);
	   PUT_LINE ('TIME_BASED_MANUAL_ENTRY            :'||p_counter_instance_tbl(tab_row).TIME_BASED_MANUAL_ENTRY);
	   PUT_LINE ('EAM_REQUIRED_FLAG                  :'||p_counter_instance_tbl(tab_row).EAM_REQUIRED_FLAG);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_counter_instance_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_counter_instance_tbl;

PROCEDURE dump_ctr_properties_rec
   (p_ctr_properties_rec IN  csi_ctr_datastructures_pub.ctr_properties_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_properties_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT  dump_ctr_properties_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Properties Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_PROPERTY_ID      :'||p_ctr_properties_rec.COUNTER_PROPERTY_ID);
   PUT_LINE ('COUNTER_ID               :'||p_ctr_properties_rec.COUNTER_ID);
   PUT_LINE ('PROPERTY_DATA_TYPE       :'||p_ctr_properties_rec.PROPERTY_DATA_TYPE);
   PUT_LINE ('IS_NULLABLE              :'||p_ctr_properties_rec.IS_NULLABLE);
   PUT_LINE ('DEFAULT_VALUE            :'||p_ctr_properties_rec.DEFAULT_VALUE);
   PUT_LINE ('MINIMUM_VALUE            :'||p_ctr_properties_rec.MINIMUM_VALUE);
   PUT_LINE ('MAXIMUM_VALUE            :'||p_ctr_properties_rec.MAXIMUM_VALUE);
   PUT_LINE ('UOM_CODE                 :'||p_ctr_properties_rec.UOM_CODE);
   PUT_LINE ('START_DATE_ACTIVE        :'||p_ctr_properties_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE          :'||p_ctr_properties_rec.END_DATE_ACTIVE);
   PUT_LINE ('OBJECT_VERSION_NUMBER    :'||p_ctr_properties_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1               :'||p_ctr_properties_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2               :'||p_ctr_properties_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3               :'||p_ctr_properties_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4               :'||p_ctr_properties_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5               :'||p_ctr_properties_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6               :'||p_ctr_properties_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7               :'||p_ctr_properties_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8               :'||p_ctr_properties_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9               :'||p_ctr_properties_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10              :'||p_ctr_properties_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11              :'||p_ctr_properties_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12              :'||p_ctr_properties_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13              :'||p_ctr_properties_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14              :'||p_ctr_properties_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15              :'||p_ctr_properties_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY       :'||p_ctr_properties_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('PROPERTY_LOV_TYPE        :'||p_ctr_properties_rec.PROPERTY_LOV_TYPE);
   PUT_LINE ('SECURITY_GROUP_ID        :'||p_ctr_properties_rec.SECURITY_GROUP_ID);
   PUT_LINE ('CREATED_FROM_CTR_PROP_TMPL_ID  :'||p_ctr_properties_rec.CREATED_FROM_CTR_PROP_TMPL_ID);
   PUT_LINE ('NAME                     :'||p_ctr_properties_rec.NAME);
   PUT_LINE ('DESCRIPTION              :'||p_ctr_properties_rec.DESCRIPTION);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_properties_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_properties_rec;

PROCEDURE dump_ctr_properties_tbl
   (p_ctr_properties_tbl IN  csi_ctr_datastructures_pub.ctr_properties_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_properties_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_properties_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_properties_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_properties_tbl.FIRST .. p_ctr_properties_tbl.LAST
      LOOP
         IF p_ctr_properties_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Properties Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_PROPERTY_ID      :'||p_ctr_properties_tbl(tab_row).COUNTER_PROPERTY_ID);
	   PUT_LINE ('COUNTER_ID               :'||p_ctr_properties_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('PROPERTY_DATA_TYPE       :'||p_ctr_properties_tbl(tab_row).PROPERTY_DATA_TYPE);
	   PUT_LINE ('IS_NULLABLE              :'||p_ctr_properties_tbl(tab_row).IS_NULLABLE);
	   PUT_LINE ('DEFAULT_VALUE            :'||p_ctr_properties_tbl(tab_row).DEFAULT_VALUE);
	   PUT_LINE ('MINIMUM_VALUE            :'||p_ctr_properties_tbl(tab_row).MINIMUM_VALUE);
	   PUT_LINE ('MAXIMUM_VALUE            :'||p_ctr_properties_tbl(tab_row).MAXIMUM_VALUE);
	   PUT_LINE ('UOM_CODE                 :'||p_ctr_properties_tbl(tab_row).UOM_CODE);
	   PUT_LINE ('START_DATE_ACTIVE        :'||p_ctr_properties_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE          :'||p_ctr_properties_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER    :'||p_ctr_properties_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9               :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10              :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11              :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12              :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13              :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14              :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15              :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY       :'||p_ctr_properties_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('PROPERTY_LOV_TYPE        :'||p_ctr_properties_tbl(tab_row).PROPERTY_LOV_TYPE);
           PUT_LINE ('SECURITY_GROUP_ID        :'||p_ctr_properties_tbl(tab_row).SECURITY_GROUP_ID);
           PUT_LINE ('CREATED_FROM_CTR_PROP_TMPL_ID  :'||p_ctr_properties_tbl(tab_row).CREATED_FROM_CTR_PROP_TMPL_ID);
	   PUT_LINE ('NAME                     :'||p_ctr_properties_tbl(tab_row).NAME);
	   PUT_LINE ('DESCRIPTION              :'||p_ctr_properties_tbl(tab_row).DESCRIPTION);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_properties_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_properties_tbl;

PROCEDURE dump_counter_associations_rec
   (p_counter_associations_rec IN  csi_ctr_datastructures_pub.counter_associations_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_counter_associations_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dump_counter_associations_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Instance Association Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('INSTANCE_ASSOCIATION_ID   :'||p_counter_associations_rec.INSTANCE_ASSOCIATION_ID);
   PUT_LINE ('SOURCE_OBJECT_CODE        :'||p_counter_associations_rec.SOURCE_OBJECT_CODE);
   PUT_LINE ('SOURCE_OBJECT_ID          :'||p_counter_associations_rec.SOURCE_OBJECT_ID);
   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_counter_associations_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                :'||p_counter_associations_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                :'||p_counter_associations_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                :'||p_counter_associations_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                :'||p_counter_associations_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                :'||p_counter_associations_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                :'||p_counter_associations_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                :'||p_counter_associations_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                :'||p_counter_associations_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                :'||p_counter_associations_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10               :'||p_counter_associations_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11               :'||p_counter_associations_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12               :'||p_counter_associations_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13               :'||p_counter_associations_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14               :'||p_counter_associations_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15               :'||p_counter_associations_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_counter_associations_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('SECURITY_GROUP_ID         :'||p_counter_associations_rec.SECURITY_GROUP_ID);
   PUT_LINE ('COUNTER_ID                :'||p_counter_associations_rec.COUNTER_ID);
   PUT_LINE ('START_DATE_ACTIVE         :'||p_counter_associations_rec.START_DATE_ACTIVE);
   PUT_LINE ('END_DATE_ACTIVE           :'||p_counter_associations_rec.END_DATE_ACTIVE);
   PUT_LINE ('MAINT_ORGANIZATION_ID     :'||p_counter_associations_rec.MAINT_ORGANIZATION_ID);
   PUT_LINE ('PRIMARY_FAILURE_FLAG      :'||p_counter_associations_rec.PRIMARY_FAILURE_FLAG);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_counter_associations_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_counter_associations_rec;

PROCEDURE dump_counter_associations_tbl
   (p_counter_associations_tbl IN  csi_ctr_datastructures_pub.counter_associations_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_counter_associations_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_counter_associations_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_counter_associations_tbl.COUNT > 0 THEN
      FOR tab_row IN p_counter_associations_tbl.FIRST .. p_counter_associations_tbl.LAST
      LOOP
         IF p_counter_associations_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter  Instance Association Table Record # : '||tab_row);
	   PUT_LINE (' 					     ');

	   PUT_LINE ('INSTANCE_ASSOCIATION_ID   :'||p_counter_associations_tbl(tab_row).INSTANCE_ASSOCIATION_ID);
	   PUT_LINE ('SOURCE_OBJECT_CODE        :'||p_counter_associations_tbl(tab_row).SOURCE_OBJECT_CODE);
	   PUT_LINE ('SOURCE_OBJECT_ID          :'||p_counter_associations_tbl(tab_row).SOURCE_OBJECT_ID);
	   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_counter_associations_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                :'||p_counter_associations_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10               :'||p_counter_associations_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11               :'||p_counter_associations_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12               :'||p_counter_associations_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13               :'||p_counter_associations_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14               :'||p_counter_associations_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15               :'||p_counter_associations_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_counter_associations_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('SECURITY_GROUP_ID         :'||p_counter_associations_tbl(tab_row).SECURITY_GROUP_ID);
	   PUT_LINE ('COUNTER_ID                :'||p_counter_associations_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('START_DATE_ACTIVE         :'||p_counter_associations_tbl(tab_row).START_DATE_ACTIVE);
	   PUT_LINE ('END_DATE_ACTIVE           :'||p_counter_associations_tbl(tab_row).END_DATE_ACTIVE);
	   PUT_LINE ('MAINT_ORGANIZATION_ID     :'||p_counter_associations_tbl(tab_row).MAINT_ORGANIZATION_ID);
	   PUT_LINE ('PRIMARY_FAILURE_FLAG      :'||p_counter_associations_tbl(tab_row).PRIMARY_FAILURE_FLAG);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_counter_associations_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_counter_associations_tbl;

PROCEDURE dump_counter_readings_rec
   (p_counter_readings_rec IN  csi_ctr_datastructures_pub.counter_readings_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_counter_readings_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dump_counter_readings_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Readings Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_VALUE_ID            :'||p_counter_readings_rec.COUNTER_VALUE_ID);
   PUT_LINE ('COUNTER_ID                  :'||p_counter_readings_rec.COUNTER_ID);
   PUT_LINE ('VALUE_TIMESTAMP             :'||p_counter_readings_rec.VALUE_TIMESTAMP);
   -- PUT_LINE ('SEQ_NO                      :'||p_counter_readings_rec.SEQ_NO);
   PUT_LINE ('COUNTER_READING             :'||p_counter_readings_rec.COUNTER_READING);
   PUT_LINE ('RESET_MODE                  :'||p_counter_readings_rec.RESET_MODE);
   PUT_LINE ('RESET_REASON                :'||p_counter_readings_rec.RESET_REASON);
   -- PUT_LINE ('READING_BEFORE_RESET        :'||p_counter_readings_rec.READING_BEFORE_RESET);
   -- PUT_LINE ('READING_AFTER_RESET         :'||p_counter_readings_rec.READING_AFTER_RESET);
   PUT_LINE ('ADJUSTMENT_TYPE             :'||p_counter_readings_rec.ADJUSTMENT_TYPE);
   PUT_LINE ('ADJUSTMENT_READING          :'||p_counter_readings_rec.ADJUSTMENT_READING);
   -- PUT_LINE ('CUMULATIVE_ADJUSTMENT       :'||p_counter_readings_rec.CUMULATIVE_ADJUSTMENT);
   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_counter_readings_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                  :'||p_counter_readings_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                  :'||p_counter_readings_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                  :'||p_counter_readings_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                  :'||p_counter_readings_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                  :'||p_counter_readings_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                  :'||p_counter_readings_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                  :'||p_counter_readings_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                  :'||p_counter_readings_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                  :'||p_counter_readings_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                 :'||p_counter_readings_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                 :'||p_counter_readings_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                 :'||p_counter_readings_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                 :'||p_counter_readings_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                 :'||p_counter_readings_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                 :'||p_counter_readings_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE16                 :'||p_counter_readings_rec.ATTRIBUTE16);
   PUT_LINE ('ATTRIBUTE17                 :'||p_counter_readings_rec.ATTRIBUTE17);
   PUT_LINE ('ATTRIBUTE18                 :'||p_counter_readings_rec.ATTRIBUTE18);
   PUT_LINE ('ATTRIBUTE19                 :'||p_counter_readings_rec.ATTRIBUTE19);
   PUT_LINE ('ATTRIBUTE20                 :'||p_counter_readings_rec.ATTRIBUTE20);
   PUT_LINE ('ATTRIBUTE21                 :'||p_counter_readings_rec.ATTRIBUTE21);
   PUT_LINE ('ATTRIBUTE22                 :'||p_counter_readings_rec.ATTRIBUTE22);
   PUT_LINE ('ATTRIBUTE23                 :'||p_counter_readings_rec.ATTRIBUTE23);
   PUT_LINE ('ATTRIBUTE24                 :'||p_counter_readings_rec.ATTRIBUTE24);
   PUT_LINE ('ATTRIBUTE25                 :'||p_counter_readings_rec.ATTRIBUTE25);
   PUT_LINE ('ATTRIBUTE26                 :'||p_counter_readings_rec.ATTRIBUTE26);
   PUT_LINE ('ATTRIBUTE27                 :'||p_counter_readings_rec.ATTRIBUTE27);
   PUT_LINE ('ATTRIBUTE28                 :'||p_counter_readings_rec.ATTRIBUTE28);
   PUT_LINE ('ATTRIBUTE29                 :'||p_counter_readings_rec.ATTRIBUTE29);
   PUT_LINE ('ATTRIBUTE30                 :'||p_counter_readings_rec.ATTRIBUTE30);
   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_counter_readings_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('COMMENTS                    :'||p_counter_readings_rec.COMMENTS);
   PUT_LINE ('LIFE_TO_DATE_READING        :'||p_counter_readings_rec.LIFE_TO_DATE_READING);
   PUT_LINE ('TRANSACTION_ID  :'||p_counter_readings_rec.TRANSACTION_ID);
   PUT_LINE ('AUTOMATIC_ROLLOVER_FLAG        :'||p_counter_readings_rec.AUTOMATIC_ROLLOVER_FLAG);
   PUT_LINE ('INCLUDE_TARGET_RESETS        :'||p_counter_readings_rec.INCLUDE_TARGET_RESETS);
   PUT_LINE ('SOURCE_COUNTER_VALUE_ID      :'||p_counter_readings_rec.SOURCE_COUNTER_VALUE_ID);
   PUT_LINE ('NET_READING                 :'||p_counter_readings_rec.NET_READING);
   PUT_LINE ('DISABLED_FLAG               :'||p_counter_readings_rec.DISABLED_FLAG);
   PUT_LINE ('SOURCE_CODE               :'||p_counter_readings_rec.SOURCE_CODE);
   PUT_LINE ('SOURCE_LINE_ID               :'||p_counter_readings_rec.SOURCE_LINE_ID);
   PUT_LINE ('RESET_COUNTER_READING      :'||p_counter_readings_rec.RESET_COUNTER_READING);
   PUT_LINE ('PARENT_TBL_INDEX           :'||p_counter_readings_rec.PARENT_TBL_INDEX);
   PUT_LINE ('INITIAL_READING_FLAG       :'||p_counter_readings_rec.INITIAL_READING_FLAG);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_counter_readings_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_counter_readings_rec;

PROCEDURE dump_counter_readings_tbl
   (p_counter_readings_tbl IN  csi_ctr_datastructures_pub.counter_readings_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_counter_readings_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_counter_readings_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_counter_readings_tbl.COUNT > 0 THEN
      FOR tab_row IN p_counter_readings_tbl.FIRST .. p_counter_readings_tbl.LAST
      LOOP
         IF p_counter_readings_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Readings Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_VALUE_ID            :'||p_counter_readings_tbl(tab_row).COUNTER_VALUE_ID);
	   PUT_LINE ('COUNTER_ID                  :'||p_counter_readings_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('VALUE_TIMESTAMP             :'||p_counter_readings_tbl(tab_row).VALUE_TIMESTAMP);
  	   -- PUT_LINE ('SEQ_NO                      :'||p_counter_readings_tbl(tab_row).SEQ_NO);
   	   PUT_LINE ('COUNTER_READING             :'||p_counter_readings_tbl(tab_row).COUNTER_READING);
	   PUT_LINE ('RESET_MODE                  :'||p_counter_readings_tbl(tab_row).RESET_MODE);
	   PUT_LINE ('RESET_REASON                :'||p_counter_readings_tbl(tab_row).RESET_REASON);
	   -- PUT_LINE ('READING_BEFORE_RESET        :'||p_counter_readings_tbl(tab_row).READING_BEFORE_RESET);
	   -- PUT_LINE ('READING_AFTER_RESET         :'||p_counter_readings_tbl(tab_row).READING_AFTER_RESET);
	   PUT_LINE ('ADJUSTMENT_TYPE             :'||p_counter_readings_tbl(tab_row).ADJUSTMENT_TYPE);
	   PUT_LINE ('ADJUSTMENT_READING          :'||p_counter_readings_tbl(tab_row).ADJUSTMENT_READING);
	   -- PUT_LINE ('CUMULATIVE_ADJUSTMENT       :'||p_counter_readings_tbl(tab_row).CUMULATIVE_ADJUSTMENT);
	   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_counter_readings_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                  :'||p_counter_readings_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE11);
 	   PUT_LINE ('ATTRIBUTE12                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE16                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE16);
	   PUT_LINE ('ATTRIBUTE17                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE17);
	   PUT_LINE ('ATTRIBUTE18                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE18);
	   PUT_LINE ('ATTRIBUTE19                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE19);
	   PUT_LINE ('ATTRIBUTE20                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE20);
	   PUT_LINE ('ATTRIBUTE21                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE21);
	   PUT_LINE ('ATTRIBUTE22                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE22);
	   PUT_LINE ('ATTRIBUTE23                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE23);
	   PUT_LINE ('ATTRIBUTE24                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE24);
	   PUT_LINE ('ATTRIBUTE25                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE25);
	   PUT_LINE ('ATTRIBUTE26                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE26);
	   PUT_LINE ('ATTRIBUTE27                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE27);
	   PUT_LINE ('ATTRIBUTE28                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE28);
	   PUT_LINE ('ATTRIBUTE29                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE29);
	   PUT_LINE ('ATTRIBUTE30                 :'||p_counter_readings_tbl(tab_row).ATTRIBUTE30);
	   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_counter_readings_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('COMMENTS                    :'||p_counter_readings_tbl(tab_row).COMMENTS);
	   PUT_LINE ('LIFE_TO_DATE_READING        :'||p_counter_readings_tbl(tab_row).LIFE_TO_DATE_READING);
           PUT_LINE ('TRANSACTION_ID  :'||p_counter_readings_tbl(tab_row).TRANSACTION_ID);
           PUT_LINE ('AUTOMATIC_ROLLOVER_FLAG        :'||p_counter_readings_tbl(tab_row).AUTOMATIC_ROLLOVER_FLAG);
           PUT_LINE ('INCLUDE_TARGET_RESETS        :'||p_counter_readings_tbl(tab_row).INCLUDE_TARGET_RESETS);
           PUT_LINE ('SOURCE_COUNTER_VALUE_ID      :'||p_counter_readings_tbl(tab_row).SOURCE_COUNTER_VALUE_ID);
           PUT_LINE ('NET_READING                 :'||p_counter_readings_tbl(tab_row).NET_READING);
           PUT_LINE ('DISABLED_FLAG               :'||p_counter_readings_tbl(tab_row).DISABLED_FLAG);
           PUT_LINE ('SOURCE_CODE               :'||p_counter_readings_tbl(tab_row).SOURCE_CODE);
           PUT_LINE ('SOURCE_LINE_ID               :'||p_counter_readings_tbl(tab_row).SOURCE_LINE_ID);
   PUT_LINE ('SECURITY_GROUP_ID               :'||p_counter_readings_tbl(tab_row).SECURITY_GROUP_ID);
	   -- PUT_LINE ('SOURCE_TRANSACTION_TYPE_ID  :'||p_counter_readings_tbl(tab_row).SOURCE_TRANSACTION_TYPE_ID);
	   -- PUT_LINE ('SOURCE_TRANSACTION_ID       :'||p_counter_readings_tbl(tab_row).SOURCE_TRANSACTION_ID);
	   PUT_LINE ('NET_READING                 :'||p_counter_readings_tbl(tab_row).NET_READING);
	   PUT_LINE ('DISABLED_FLAG               :'||p_counter_readings_tbl(tab_row).DISABLED_FLAG);
           PUT_LINE ('RESET_COUNTER_READING      :'||p_counter_readings_tbl(tab_row).RESET_COUNTER_READING);
	   PUT_LINE ('PARENT_TBL_INDEX            :'||p_counter_readings_tbl(tab_row).PARENT_TBL_INDEX);
           PUT_LINE ('INITIAL_READING_FLAG       :'||p_counter_readings_tbl(tab_row).INITIAL_READING_FLAG);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_counter_readings_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_counter_readings_tbl;

PROCEDURE dump_ctr_property_readings_rec
   (p_ctr_property_readings_rec IN  csi_ctr_datastructures_pub.ctr_property_readings_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_property_readings_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dump_ctr_property_readings_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Property Readings Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_PROP_VALUE_ID       :'||p_ctr_property_readings_rec.COUNTER_PROP_VALUE_ID);
   PUT_LINE ('COUNTER_VALUE_ID            :'||p_ctr_property_readings_rec.COUNTER_VALUE_ID);
   PUT_LINE ('COUNTER_PROPERTY_ID         :'||p_ctr_property_readings_rec.COUNTER_PROPERTY_ID);
   PUT_LINE ('PROPERTY_VALUE              :'||p_ctr_property_readings_rec.PROPERTY_VALUE);
   PUT_LINE ('VALUE_TIMESTAMP             :'||p_ctr_property_readings_rec.VALUE_TIMESTAMP);
   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_property_readings_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_property_readings_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_property_readings_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_property_readings_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_property_readings_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_property_readings_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_property_readings_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_property_readings_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_property_readings_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_property_readings_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_property_readings_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_property_readings_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_property_readings_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_property_readings_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_property_readings_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_property_readings_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_property_readings_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('SECURITY_GROUP_ID           :'||p_ctr_property_readings_rec.SECURITY_GROUP_ID);
   PUT_LINE ('PARENT_TBL_INDEX           :'||p_ctr_property_readings_rec.PARENT_TBL_INDEX);


EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_property_readings_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_property_readings_rec;

PROCEDURE dump_ctr_property_readings_tbl
   (p_ctr_property_readings_tbl IN  csi_ctr_datastructures_pub.ctr_property_readings_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_property_readings_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_property_readings_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_property_readings_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_property_readings_tbl.FIRST .. p_ctr_property_readings_tbl.LAST
      LOOP
         IF p_ctr_property_readings_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Property Readings Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_PROP_VALUE_ID       :'||p_ctr_property_readings_tbl(tab_row).COUNTER_PROP_VALUE_ID);
	   PUT_LINE ('COUNTER_VALUE_ID            :'||p_ctr_property_readings_tbl(tab_row).COUNTER_VALUE_ID);
	   PUT_LINE ('COUNTER_PROPERTY_ID         :'||p_ctr_property_readings_tbl(tab_row).COUNTER_PROPERTY_ID);
	   PUT_LINE ('PROPERTY_VALUE              :'||p_ctr_property_readings_tbl(tab_row).PROPERTY_VALUE);
	   PUT_LINE ('VALUE_TIMESTAMP             :'||p_ctr_property_readings_tbl(tab_row).VALUE_TIMESTAMP);
	   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_property_readings_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_property_readings_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('PARENT_TBL_INDEX            :'||p_ctr_property_readings_tbl(tab_row).PARENT_TBL_INDEX);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_property_readings_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_property_readings_tbl;

PROCEDURE dump_ctr_usage_forecast_rec
   (p_ctr_usage_forecast_rec IN  csi_ctr_datastructures_pub.ctr_usage_forecast_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_usage_forecast_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dump_ctr_usage_forecast_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Usage Forecast Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('INSTANCE_FORECAST_ID      :'||p_ctr_usage_forecast_rec.INSTANCE_FORECAST_ID);
   PUT_LINE ('COUNTER_ID                :'||p_ctr_usage_forecast_rec.COUNTER_ID);
   PUT_LINE ('USAGE_RATE                :'||p_ctr_usage_forecast_rec.USAGE_RATE);
   PUT_LINE ('USE_PAST_READING          :'||p_ctr_usage_forecast_rec.USE_PAST_READING);
   PUT_LINE ('ACTIVE_START_DATE         :'||p_ctr_usage_forecast_rec.ACTIVE_START_DATE);
   PUT_LINE ('ACTIVE_END_DATE           :'||p_ctr_usage_forecast_rec.ACTIVE_END_DATE);
   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_usage_forecast_rec.OBJECT_VERSION_NUMBER);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_usage_forecast_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_usage_forecast_rec;

PROCEDURE dump_ctr_usage_forecast_tbl
   (p_ctr_usage_forecast_tbl IN  csi_ctr_datastructures_pub.ctr_usage_forecast_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_usage_forecast_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_usage_forecast_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_usage_forecast_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_usage_forecast_tbl.FIRST .. p_ctr_usage_forecast_tbl.LAST
      LOOP
         IF p_ctr_usage_forecast_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Usage Forecast Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('INSTANCE_FORECAST_ID      :'||p_ctr_usage_forecast_tbl(tab_row).INSTANCE_FORECAST_ID);
	   PUT_LINE ('COUNTER_ID                :'||p_ctr_usage_forecast_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('USAGE_RATE                :'||p_ctr_usage_forecast_tbl(tab_row).USAGE_RATE);
	   PUT_LINE ('USE_PAST_READING          :'||p_ctr_usage_forecast_tbl(tab_row).USE_PAST_READING);
	   PUT_LINE ('ACTIVE_START_DATE         :'||p_ctr_usage_forecast_tbl(tab_row).ACTIVE_START_DATE);
	   PUT_LINE ('ACTIVE_END_DATE           :'||p_ctr_usage_forecast_tbl(tab_row).ACTIVE_END_DATE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_usage_forecast_tbl(tab_row).OBJECT_VERSION_NUMBER);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_usage_forecast_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name,
            l_api_name);
      END IF;
END dump_ctr_usage_forecast_tbl;

PROCEDURE dump_ctr_reading_lock_rec
   (p_ctr_reading_lock_rec IN  csi_ctr_datastructures_pub.ctr_reading_lock_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_reading_lock_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
  SAVEPOINT dump_ctr_reading_lock_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Reading Lock Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('READING_LOCK_ID           :'||p_ctr_reading_lock_rec.READING_LOCK_ID);
   PUT_LINE ('READING_LOCK_DATE         :'||p_ctr_reading_lock_rec.READING_LOCK_DATE);
   PUT_LINE ('ACTIVE_START_DATE         :'||p_ctr_reading_lock_rec.ACTIVE_START_DATE);
   PUT_LINE ('ACTIVE_END_DATE           :'||p_ctr_reading_lock_rec.ACTIVE_END_DATE);
   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_reading_lock_rec.OBJECT_VERSION_NUMBER);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_ctr_reading_lock_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dump_ctr_reading_lock_rec;

PROCEDURE dump_ctr_reading_lock_tbl
   (p_ctr_reading_lock_tbl IN  csi_ctr_datastructures_pub.ctr_reading_lock_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dump_ctr_reading_lock_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
   SAVEPOINT dump_ctr_reading_lock_tbl;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_reading_lock_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_reading_lock_tbl.FIRST .. p_ctr_reading_lock_tbl.LAST
      LOOP
         IF p_ctr_reading_lock_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Reading Lock Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('READING_LOCK_ID           :'||p_ctr_reading_lock_tbl(tab_row).READING_LOCK_ID);
	   PUT_LINE ('READING_LOCK_DATE         :'||p_ctr_reading_lock_tbl(tab_row).READING_LOCK_DATE);
	   PUT_LINE ('ACTIVE_START_DATE         :'||p_ctr_reading_lock_tbl(tab_row).ACTIVE_START_DATE);
	   PUT_LINE ('ACTIVE_END_DATE           :'||p_ctr_reading_lock_tbl(tab_row).ACTIVE_END_DATE);
	   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_reading_lock_tbl(tab_row).OBJECT_VERSION_NUMBER);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dump_ctr_reading_lock_tbl;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, l_api_name);
      END IF;
END dump_ctr_reading_lock_tbl;

PROCEDURE dm_ctr_estimated_readings_rec
   (p_ctr_estimated_readings_rec IN  csi_ctr_datastructures_pub.ctr_estimated_readings_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_estimated_readings_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dm_ctr_estimated_readings_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Estimated Readings Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('ESTIMATED_READING_ID        :'||p_ctr_estimated_readings_rec.ESTIMATED_READING_ID);
   PUT_LINE ('COUNTER_ID                  :'||p_ctr_estimated_readings_rec.COUNTER_ID);
   PUT_LINE ('ESTIMATION_ID               :'||p_ctr_estimated_readings_rec.ESTIMATION_ID);
   PUT_LINE ('VALUE_TIMESTAMP             :'||p_ctr_estimated_readings_rec.VALUE_TIMESTAMP);
   PUT_LINE ('ESTIMATED_METER_READING     :'||p_ctr_estimated_readings_rec.ESTIMATED_METER_READING);
   PUT_LINE ('NUM_OF_READINGS             :'||p_ctr_estimated_readings_rec.NUM_OF_READINGS);
   PUT_LINE ('PERIOD_START_DATE           :'||p_ctr_estimated_readings_rec.PERIOD_START_DATE);
   PUT_LINE ('PERIOD_END_DATE             :'||p_ctr_estimated_readings_rec.PERIOD_END_DATE);
   PUT_LINE ('AVG_CALCULATION_START_DATE  :'||p_ctr_estimated_readings_rec.AVG_CALCULATION_START_DATE);
   PUT_LINE ('ESTIMATED_USAGE             :'||p_ctr_estimated_readings_rec.ESTIMATED_USAGE);
   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_estimated_readings_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_estimated_readings_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_estimated_readings_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_estimated_readings_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_estimated_readings_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_estimated_readings_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_estimated_readings_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_estimated_readings_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_estimated_readings_rec.OBJECT_VERSION_NUMBER);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_estimated_readings_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dm_ctr_estimated_readings_rec;

PROCEDURE dm_ctr_estimated_readings_tbl
   (p_ctr_estimated_readings_tbl IN  csi_ctr_datastructures_pub.ctr_estimated_readings_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_estimated_readings_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
  SAVEPOINT dm_ctr_estimated_readings_tbl;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_estimated_readings_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_estimated_readings_tbl.FIRST .. p_ctr_estimated_readings_tbl.LAST
      LOOP
         IF p_ctr_estimated_readings_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Estimated Readings Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('ESTIMATED_READING_ID        :'||p_ctr_estimated_readings_tbl(tab_row).ESTIMATED_READING_ID);
	   PUT_LINE ('COUNTER_ID                  :'||p_ctr_estimated_readings_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('ESTIMATION_ID               :'||p_ctr_estimated_readings_tbl(tab_row).ESTIMATION_ID);
	   PUT_LINE ('VALUE_TIMESTAMP             :'||p_ctr_estimated_readings_tbl(tab_row).VALUE_TIMESTAMP);
	   PUT_LINE ('ESTIMATED_METER_READING     :'||p_ctr_estimated_readings_tbl(tab_row).ESTIMATED_METER_READING);
	   PUT_LINE ('NUM_OF_READINGS             :'||p_ctr_estimated_readings_tbl(tab_row).NUM_OF_READINGS);
	   PUT_LINE ('PERIOD_START_DATE           :'||p_ctr_estimated_readings_tbl(tab_row).PERIOD_START_DATE);
	   PUT_LINE ('PERIOD_END_DATE             :'||p_ctr_estimated_readings_tbl(tab_row).PERIOD_END_DATE);
 	   PUT_LINE ('AVG_CALCULATION_START_DATE  :'||p_ctr_estimated_readings_tbl(tab_row).AVG_CALCULATION_START_DATE);
	   PUT_LINE ('ESTIMATED_USAGE             :'||p_ctr_estimated_readings_tbl(tab_row).ESTIMATED_USAGE);
	   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE12);
 	   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_estimated_readings_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_estimated_readings_tbl(tab_row).OBJECT_VERSION_NUMBER);

        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_estimated_readings_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name, l_api_name);
      END IF;
END dm_ctr_estimated_readings_tbl;

PROCEDURE dm_ctr_readings_interface_rec
   (p_ctr_readings_interface_rec IN  csi_ctr_datastructures_pub.ctr_readings_interface_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_readings_interface_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
   SAVEPOINT dm_ctr_readings_interface_rec;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Readings Open Interface Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_INTERFACE_ID        :'||p_ctr_readings_interface_rec.COUNTER_INTERFACE_ID);
   PUT_LINE ('PARALLEL_WORKER_ID          :'||p_ctr_readings_interface_rec.PARALLEL_WORKER_ID);
   PUT_LINE ('BATCH_NAME                  :'||p_ctr_readings_interface_rec.BATCH_NAME);
   PUT_LINE ('SOURCE_TRANSACTION_DATE     :'||p_ctr_readings_interface_rec.SOURCE_TRANSACTION_DATE);
   PUT_LINE ('PROCESS_STATUS              :'||p_ctr_readings_interface_rec.PROCESS_STATUS);
   PUT_LINE ('ERROR_TEXT                  :'||p_ctr_readings_interface_rec.ERROR_TEXT);
   PUT_LINE ('COUNTER_VALUE_ID            :'||p_ctr_readings_interface_rec.COUNTER_VALUE_ID);
   PUT_LINE ('COUNTER_ID                  :'||p_ctr_readings_interface_rec.COUNTER_ID);
   PUT_LINE ('VALUE_TIMESTAMP             :'||p_ctr_readings_interface_rec.VALUE_TIMESTAMP);
   PUT_LINE ('COUNTER_READING             :'||p_ctr_readings_interface_rec.COUNTER_READING);
   PUT_LINE ('RESET_MODE                  :'||p_ctr_readings_interface_rec.RESET_MODE);
   PUT_LINE ('RESET_REASON                :'||p_ctr_readings_interface_rec.RESET_REASON);
   PUT_LINE ('ADJUSTMENT_TYPE             :'||p_ctr_readings_interface_rec.ADJUSTMENT_TYPE);
   PUT_LINE ('ADJUSTMENT_READING          :'||p_ctr_readings_interface_rec.ADJUSTMENT_READING);
   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_readings_interface_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_readings_interface_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_readings_interface_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_readings_interface_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_readings_interface_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_readings_interface_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_readings_interface_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_readings_interface_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_readings_interface_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_readings_interface_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_readings_interface_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_readings_interface_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_readings_interface_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_readings_interface_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_readings_interface_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_readings_interface_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE16                 :'||p_ctr_readings_interface_rec.ATTRIBUTE16);
   PUT_LINE ('ATTRIBUTE17                 :'||p_ctr_readings_interface_rec.ATTRIBUTE17);
   PUT_LINE ('ATTRIBUTE18                 :'||p_ctr_readings_interface_rec.ATTRIBUTE18);
   PUT_LINE ('ATTRIBUTE19                 :'||p_ctr_readings_interface_rec.ATTRIBUTE19);
   PUT_LINE ('ATTRIBUTE20                 :'||p_ctr_readings_interface_rec.ATTRIBUTE20);
   PUT_LINE ('ATTRIBUTE21                 :'||p_ctr_readings_interface_rec.ATTRIBUTE21);
   PUT_LINE ('ATTRIBUTE22                 :'||p_ctr_readings_interface_rec.ATTRIBUTE22);
   PUT_LINE ('ATTRIBUTE23                 :'||p_ctr_readings_interface_rec.ATTRIBUTE23);
   PUT_LINE ('ATTRIBUTE24                 :'||p_ctr_readings_interface_rec.ATTRIBUTE24);
   PUT_LINE ('ATTRIBUTE25                 :'||p_ctr_readings_interface_rec.ATTRIBUTE25);
   PUT_LINE ('ATTRIBUTE26                 :'||p_ctr_readings_interface_rec.ATTRIBUTE26);
   PUT_LINE ('ATTRIBUTE27                 :'||p_ctr_readings_interface_rec.ATTRIBUTE27);
   PUT_LINE ('ATTRIBUTE28                 :'||p_ctr_readings_interface_rec.ATTRIBUTE28);
   PUT_LINE ('ATTRIBUTE29                 :'||p_ctr_readings_interface_rec.ATTRIBUTE29);
   PUT_LINE ('ATTRIBUTE30                 :'||p_ctr_readings_interface_rec.ATTRIBUTE30);
   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_readings_interface_rec.ATTRIBUTE_CATEGORY);
   PUT_LINE ('COMMENTS                    :'||p_ctr_readings_interface_rec.COMMENTS);
   PUT_LINE ('LIFE_TO_DATE_READING        :'||p_ctr_readings_interface_rec.LIFE_TO_DATE_READING);
   PUT_LINE ('NET_READING                 :'||p_ctr_readings_interface_rec.NET_READING);
   PUT_LINE ('DISABLED_FLAG               :'||p_ctr_readings_interface_rec.DISABLED_FLAG);
   PUT_LINE ('SOURCE_CODE                 :'||p_ctr_readings_interface_rec.SOURCE_CODE);
   PUT_LINE ('SOURCE_LINE_ID              :'||p_ctr_readings_interface_rec.SOURCE_LINE_ID);
   PUT_LINE ('COUNTER_NAME                :'||p_ctr_readings_interface_rec.COUNTER_NAME);
   PUT_LINE ('INCLUDE_TARGET_RESETS       :'||p_ctr_readings_interface_rec.INCLUDE_TARGET_RESETS);
   PUT_LINE ('AUTOMATIC_ROLLOVER_FLAG     :'||p_ctr_readings_interface_rec.AUTOMATIC_ROLLOVER_FLAG);
   PUT_LINE ('SOURCE_COUNTER_VALUE_ID     :'||p_ctr_readings_interface_rec.SOURCE_COUNTER_VALUE_ID);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_readings_interface_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dm_ctr_readings_interface_rec;

PROCEDURE dm_ctr_readings_interface_tbl
   (p_ctr_readings_interface_tbl IN  csi_ctr_datastructures_pub.ctr_readings_interface_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_readings_interface_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
  SAVEPOINT dm_ctr_readings_interface_tbl;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_readings_interface_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_readings_interface_tbl.FIRST .. p_ctr_readings_interface_tbl.LAST
      LOOP
         IF p_ctr_readings_interface_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Readings Open Interface Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_INTERFACE_ID        :'||p_ctr_readings_interface_tbl(tab_row).COUNTER_INTERFACE_ID);
	   PUT_LINE ('PARALLEL_WORKER_ID          :'||p_ctr_readings_interface_tbl(tab_row).PARALLEL_WORKER_ID);
	   PUT_LINE ('BATCH_NAME                  :'||p_ctr_readings_interface_tbl(tab_row).BATCH_NAME);
	   PUT_LINE ('SOURCE_TRANSACTION_DATE     :'||p_ctr_readings_interface_tbl(tab_row).SOURCE_TRANSACTION_DATE);            	   PUT_LINE ('PROCESS_STATUS              :'||p_ctr_readings_interface_tbl(tab_row).PROCESS_STATUS);
	   PUT_LINE ('ERROR_TEXT                  :'||p_ctr_readings_interface_tbl(tab_row).ERROR_TEXT);
	   PUT_LINE ('COUNTER_VALUE_ID            :'||p_ctr_readings_interface_tbl(tab_row).COUNTER_VALUE_ID);
	   PUT_LINE ('COUNTER_ID                  :'||p_ctr_readings_interface_tbl(tab_row).COUNTER_ID);
	   PUT_LINE ('VALUE_TIMESTAMP             :'||p_ctr_readings_interface_tbl(tab_row).VALUE_TIMESTAMP);
	   PUT_LINE ('COUNTER_READING             :'||p_ctr_readings_interface_tbl(tab_row).COUNTER_READING);
	   PUT_LINE ('RESET_MODE                  :'||p_ctr_readings_interface_tbl(tab_row).RESET_MODE);
	   PUT_LINE ('RESET_REASON                :'||p_ctr_readings_interface_tbl(tab_row).RESET_REASON);
	   PUT_LINE ('ADJUSTMENT_TYPE             :'||p_ctr_readings_interface_tbl(tab_row).ADJUSTMENT_TYPE);
	   PUT_LINE ('ADJUSTMENT_READING          :'||p_ctr_readings_interface_tbl(tab_row).ADJUSTMENT_READING);
	   PUT_LINE ('OBJECT_VERSION_NUMBER       :'||p_ctr_readings_interface_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                  :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE16                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE16);
	   PUT_LINE ('ATTRIBUTE17                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE17);
	   PUT_LINE ('ATTRIBUTE18                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE18);
	   PUT_LINE ('ATTRIBUTE19                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE19);
	   PUT_LINE ('ATTRIBUTE20                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE20);
	   PUT_LINE ('ATTRIBUTE21                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE21);
	   PUT_LINE ('ATTRIBUTE22                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE22);
	   PUT_LINE ('ATTRIBUTE23                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE23);
	   PUT_LINE ('ATTRIBUTE24                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE24);
	   PUT_LINE ('ATTRIBUTE25                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE25);
	   PUT_LINE ('ATTRIBUTE26                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE26);
	   PUT_LINE ('ATTRIBUTE27                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE27);
	   PUT_LINE ('ATTRIBUTE28                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE28);
	   PUT_LINE ('ATTRIBUTE29                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE29);
	   PUT_LINE ('ATTRIBUTE30                 :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE30);
	   PUT_LINE ('ATTRIBUTE_CATEGORY          :'||p_ctr_readings_interface_tbl(tab_row).ATTRIBUTE_CATEGORY);
	   PUT_LINE ('COMMENTS                    :'||p_ctr_readings_interface_tbl(tab_row).COMMENTS);
 	   PUT_LINE ('LIFE_TO_DATE_READING        :'||p_ctr_readings_interface_tbl(tab_row).LIFE_TO_DATE_READING);
	   PUT_LINE ('NET_READING                 :'||p_ctr_readings_interface_tbl(tab_row).NET_READING);
	   PUT_LINE ('DISABLED_FLAG               :'||p_ctr_readings_interface_tbl(tab_row).DISABLED_FLAG);
	   PUT_LINE ('SOURCE_CODE                 :'||p_ctr_readings_interface_tbl(tab_row).SOURCE_CODE);
	   PUT_LINE ('SOURCE_LINE_ID              :'||p_ctr_readings_interface_tbl(tab_row).SOURCE_LINE_ID);
 	   PUT_LINE ('COUNTER_NAME                :'||p_ctr_readings_interface_tbl(tab_row).COUNTER_NAME);
           PUT_LINE ('INCLUDE_TARGET_RESETS       :'||p_ctr_readings_interface_tbl(tab_row).INCLUDE_TARGET_RESETS);
           PUT_LINE ('AUTOMATIC_ROLLOVER_FLAG     :'||p_ctr_readings_interface_tbl(tab_row).AUTOMATIC_ROLLOVER_FLAG);
           PUT_LINE ('SOURCE_COUNTER_VALUE_ID     :'||p_ctr_readings_interface_tbl(tab_row).SOURCE_COUNTER_VALUE_ID);
        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_readings_interface_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name, l_api_name);
      END IF;
END dm_ctr_readings_interface_tbl;

PROCEDURE dm_ctr_read_prop_interface_rec
   (p_ctr_read_prop_interface_rec IN  csi_ctr_datastructures_pub.ctr_read_prop_interface_rec) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_read_prop_interface_rec';
   l_api_version  CONSTANT NUMBER         := 1.0;
BEGIN
  SAVEPOINT dm_ctr_read_prop_interface_rec;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   PUT_LINE ('                                       ');
   PUT_LINE ('Dumping the values for Counter Readings Properties Interface Record:');
   PUT_LINE ('                                       ');

   PUT_LINE ('COUNTER_INTERFACE_ID      :'||p_ctr_read_prop_interface_rec.COUNTER_INTERFACE_ID);
   PUT_LINE ('PARALLEL_WORKER_ID        :'||p_ctr_read_prop_interface_rec.PARALLEL_WORKER_ID);
   PUT_LINE ('ERROR_TEXT                :'||p_ctr_read_prop_interface_rec.ERROR_TEXT);
   PUT_LINE ('COUNTER_PROP_VALUE_ID     :'||p_ctr_read_prop_interface_rec.COUNTER_PROP_VALUE_ID);
   PUT_LINE ('COUNTER_VALUE_ID          :'||p_ctr_read_prop_interface_rec.COUNTER_VALUE_ID);
   PUT_LINE ('COUNTER_PROPERTY_ID       :'||p_ctr_read_prop_interface_rec.COUNTER_PROPERTY_ID);
   PUT_LINE ('PROPERTY_VALUE            :'||p_ctr_read_prop_interface_rec.PROPERTY_VALUE);
   PUT_LINE ('VALUE_TIMESTAMP           :'||p_ctr_read_prop_interface_rec.VALUE_TIMESTAMP);
   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_read_prop_interface_rec.OBJECT_VERSION_NUMBER);
   PUT_LINE ('ATTRIBUTE1                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE1);
   PUT_LINE ('ATTRIBUTE2                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE2);
   PUT_LINE ('ATTRIBUTE3                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE3);
   PUT_LINE ('ATTRIBUTE4                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE4);
   PUT_LINE ('ATTRIBUTE5                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE5);
   PUT_LINE ('ATTRIBUTE6                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE6);
   PUT_LINE ('ATTRIBUTE7                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE7);
   PUT_LINE ('ATTRIBUTE8                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE8);
   PUT_LINE ('ATTRIBUTE9                :'||p_ctr_read_prop_interface_rec.ATTRIBUTE9);
   PUT_LINE ('ATTRIBUTE10               :'||p_ctr_read_prop_interface_rec.ATTRIBUTE10);
   PUT_LINE ('ATTRIBUTE11               :'||p_ctr_read_prop_interface_rec.ATTRIBUTE11);
   PUT_LINE ('ATTRIBUTE12               :'||p_ctr_read_prop_interface_rec.ATTRIBUTE12);
   PUT_LINE ('ATTRIBUTE13               :'||p_ctr_read_prop_interface_rec.ATTRIBUTE13);
   PUT_LINE ('ATTRIBUTE14               :'||p_ctr_read_prop_interface_rec.ATTRIBUTE14);
   PUT_LINE ('ATTRIBUTE15               :'||p_ctr_read_prop_interface_rec.ATTRIBUTE15);
   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_ctr_read_prop_interface_rec.ATTRIBUTE_CATEGORY);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_read_prop_interface_rec;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
                (g_pkg_name,
                 l_api_name);
      END IF;
END dm_ctr_read_prop_interface_rec;

PROCEDURE dm_ctr_read_prop_interface_tbl
   (p_ctr_read_prop_interface_tbl IN  csi_ctr_datastructures_pub.ctr_read_prop_interface_tbl) IS
   l_api_name     CONSTANT VARCHAR2(30)   := 'dm_ctr_read_prop_interface_tbl';
   l_api_version  CONSTANT NUMBER         := 1.0;

BEGIN
  SAVEPOINT dm_ctr_read_prop_interface_tbl;

  -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   IF p_ctr_read_prop_interface_tbl.COUNT > 0 THEN
      FOR tab_row IN p_ctr_read_prop_interface_tbl.FIRST .. p_ctr_read_prop_interface_tbl.LAST
      LOOP
         IF p_ctr_read_prop_interface_tbl.EXISTS(tab_row) THEN

	   PUT_LINE ('                                       ');
           PUT_LINE ('Dumping the values for Counter Readings Property Interface Table Record # : '||tab_row);
	   PUT_LINE ('                                       ');

	   PUT_LINE ('COUNTER_INTERFACE_ID      :'||p_ctr_read_prop_interface_tbl(tab_row).COUNTER_INTERFACE_ID);
	   PUT_LINE ('PARALLEL_WORKER_ID        :'||p_ctr_read_prop_interface_tbl(tab_row).PARALLEL_WORKER_ID);
	   PUT_LINE ('ERROR_TEXT                :'||p_ctr_read_prop_interface_tbl(tab_row).ERROR_TEXT);
	   PUT_LINE ('COUNTER_PROP_VALUE_ID     :'||p_ctr_read_prop_interface_tbl(tab_row).COUNTER_PROP_VALUE_ID);
	   PUT_LINE ('COUNTER_VALUE_ID          :'||p_ctr_read_prop_interface_tbl(tab_row).COUNTER_VALUE_ID);
	   PUT_LINE ('COUNTER_PROPERTY_ID       :'||p_ctr_read_prop_interface_tbl(tab_row).COUNTER_PROPERTY_ID);
	   PUT_LINE ('PROPERTY_VALUE            :'||p_ctr_read_prop_interface_tbl(tab_row).PROPERTY_VALUE);
	   PUT_LINE ('VALUE_TIMESTAMP           :'||p_ctr_read_prop_interface_tbl(tab_row).VALUE_TIMESTAMP);
	   PUT_LINE ('OBJECT_VERSION_NUMBER     :'||p_ctr_read_prop_interface_tbl(tab_row).OBJECT_VERSION_NUMBER);
	   PUT_LINE ('ATTRIBUTE1                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE1);
	   PUT_LINE ('ATTRIBUTE2                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE2);
	   PUT_LINE ('ATTRIBUTE3                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE3);
	   PUT_LINE ('ATTRIBUTE4                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE4);
	   PUT_LINE ('ATTRIBUTE5                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE5);
	   PUT_LINE ('ATTRIBUTE6                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE6);
	   PUT_LINE ('ATTRIBUTE7                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE7);
	   PUT_LINE ('ATTRIBUTE8                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE8);
	   PUT_LINE ('ATTRIBUTE9                :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE9);
	   PUT_LINE ('ATTRIBUTE10               :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE10);
	   PUT_LINE ('ATTRIBUTE11               :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE11);
	   PUT_LINE ('ATTRIBUTE12               :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE12);
	   PUT_LINE ('ATTRIBUTE13               :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE13);
	   PUT_LINE ('ATTRIBUTE14               :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE14);
	   PUT_LINE ('ATTRIBUTE15               :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE15);
	   PUT_LINE ('ATTRIBUTE_CATEGORY        :'||p_ctr_read_prop_interface_tbl(tab_row).ATTRIBUTE_CATEGORY);
        END IF;
     END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dm_ctr_read_prop_interface_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (g_pkg_name, l_api_name);
      END IF;
END dm_ctr_read_prop_interface_tbl;


PROCEDURE dump_txn_rec
   (p_txn_rec   IN  csi_datastructures_pub.transaction_rec) IS

   l_api_name          CONSTANT VARCHAR2(30)   := 'dump_txn_rec';
   l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN
   -- Standard Start of API savepoint
   --   SAVEPOINT       dump_txn_rec;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   put_line('                                       ');
   put_line('Dumping the values for Transaction Record:');
   put_line('                                       ');
   put_line('transaction_id               : '|| p_txn_rec.transaction_id );
   put_line('transaction_date             : '|| p_txn_rec.transaction_date );
   put_line('source_transaction_date      : '|| p_txn_rec.source_transaction_date );
   put_line('transaction_type_id          : '|| p_txn_rec.transaction_type_id );
   put_line('txn_sub_type_id              : '|| p_txn_rec.txn_sub_type_id );
   put_line('source_group_ref_id          : '|| p_txn_rec.source_group_ref_id );
   put_line('source_group_ref             : '|| p_txn_rec.source_group_ref );
   put_line('source_header_ref_id         : '|| p_txn_rec.source_header_ref_id );
   put_line('source_header_ref            : '|| p_txn_rec.source_header_ref );
   put_line('source_line_ref_id           : '|| p_txn_rec.source_line_ref_id );
   put_line('source_line_ref              : '|| p_txn_rec.source_line_ref );
   put_line('source_dist_ref_id1          : '|| p_txn_rec.source_dist_ref_id1 );
   put_line('source_dist_ref_id2          : '|| p_txn_rec.source_dist_ref_id2 );
   put_line('inv_material_transaction_id  : '|| p_txn_rec.inv_material_transaction_id );
   put_line('transaction_quantity         : '|| p_txn_rec.transaction_quantity );
   put_line('transaction_uom_code         : '|| p_txn_rec.transaction_uom_code );
   put_line('transacted_by                : '|| p_txn_rec.transacted_by );
   put_line('transaction_status_code      : '|| p_txn_rec.transaction_status_code );
   put_line('transaction_action_code      : '|| p_txn_rec.transaction_action_code );
   put_line('message_id                   : '|| p_txn_rec.message_id );
   put_line('context                      : '|| p_txn_rec.context );
   put_line('attribute1                   : '|| p_txn_rec.attribute1 );
   put_line('attribute2                   : '|| p_txn_rec.attribute2 );
   put_line('attribute3                   : '|| p_txn_rec.attribute3 );
   put_line('attribute4                   : '|| p_txn_rec.attribute4 );
   put_line('attribute5                   : '|| p_txn_rec.attribute5 );
   put_line('attribute6                   : '|| p_txn_rec.attribute6 );
   put_line('attribute7                   : '|| p_txn_rec.attribute7 );
   put_line('attribute8                   : '|| p_txn_rec.attribute8 );
   put_line('attribute9                   : '|| p_txn_rec.attribute9 );
   put_line('attribute10                  : '|| p_txn_rec.attribute10 );
   put_line('attribute11                  : '|| p_txn_rec.attribute11 );
   put_line('attribute12                  : '|| p_txn_rec.attribute12 );
   put_line('attribute13                  : '|| p_txn_rec.attribute13 );
   put_line('attribute14                  : '|| p_txn_rec.attribute14 );
   put_line('attribute15                  : '|| p_txn_rec.attribute15 );
   put_line('object_version_number        : '|| p_txn_rec.object_version_number);
   put_line('split_reason_code            : '|| p_txn_rec.split_reason_code);
EXCEPTION
   WHEN OTHERS THEN
      -- ROLLBACK TO  dump_txn_rec;

      IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
      END IF;
END dump_txn_rec;

PROCEDURE dump_txn_tbl
   (p_txn_tbl  IN  csi_datastructures_pub.transaction_tbl) IS
   l_api_name          CONSTANT VARCHAR2(30)   := 'dump_txn_tbl';
   l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT       dump_txn_tbl;
    IF p_txn_tbl.COUNT > 0 THEN
       FOR tab_row IN p_txn_tbl.FIRST .. p_txn_tbl.LAST
       LOOP
          IF p_txn_tbl.EXISTS(tab_row) THEN
             dump_txn_rec(p_txn_rec => p_txn_tbl(tab_row));
          END IF;
       END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO  dump_txn_tbl;
      IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
           (       G_PKG_NAME          ,
                   l_api_name
                 );
      END IF;
END dump_txn_tbl;
END;

/
