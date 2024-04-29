--------------------------------------------------------
--  DDL for Package Body OKC_LSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_LSS_PVT" AS
/* $Header: OKCSLSSB.pls 120.0 2005/05/25 19:31:33 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_TOO_MANY_SOURCES           CONSTANT VARCHAR2(20):='OKC_TOO_MANY_SOURCES';
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_LINE_STYLE_SOURCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lss_rec                      IN lss_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lss_rec_type IS
    CURSOR lss_pk_csr (p_lse_id             IN NUMBER,
                       p_jtot_object_code   IN VARCHAR2) IS
    SELECT
            LSE_ID,
            JTOT_OBJECT_CODE,
            START_DATE,
            OBJECT_VERSION_NUMBER,
            ACCESS_LEVEL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            END_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Line_Style_Sources
     WHERE okc_line_style_sources.lse_id = p_lse_id
       AND okc_line_style_sources.jtot_object_code = p_jtot_object_code;
    l_lss_pk                       lss_pk_csr%ROWTYPE;
    l_lss_rec                      lss_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN lss_pk_csr (p_lss_rec.lse_id,
                     p_lss_rec.jtot_object_code);
    FETCH lss_pk_csr INTO
              l_lss_rec.LSE_ID,
              l_lss_rec.JTOT_OBJECT_CODE,
              l_lss_rec.START_DATE,
              l_lss_rec.OBJECT_VERSION_NUMBER,
              l_lss_rec.ACCESS_LEVEL,
              l_lss_rec.CREATED_BY,
              l_lss_rec.CREATION_DATE,
              l_lss_rec.LAST_UPDATED_BY,
              l_lss_rec.LAST_UPDATE_DATE,
              l_lss_rec.END_DATE,
              l_lss_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := lss_pk_csr%NOTFOUND;
    CLOSE lss_pk_csr;
    RETURN(l_lss_rec);
  END get_rec;

  FUNCTION get_rec (
    p_lss_rec                      IN lss_rec_type
  ) RETURN lss_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lss_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_LINE_STYLE_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lssv_rec                     IN lssv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lssv_rec_type IS
    CURSOR okc_lssv_pk_csr (p_lse_id             IN NUMBER,
                            p_jtot_object_code   IN VARCHAR2) IS
    SELECT
            LSE_ID,
            JTOT_OBJECT_CODE,
            OBJECT_VERSION_NUMBER,
            ACCESS_LEVEL,
            START_DATE,
            END_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Line_Style_Sources
     WHERE okc_line_style_sources.lse_id = p_lse_id
       AND okc_line_style_sources.jtot_object_code = p_jtot_object_code;
    l_okc_lssv_pk                  okc_lssv_pk_csr%ROWTYPE;
    l_lssv_rec                     lssv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_lssv_pk_csr (p_lssv_rec.lse_id,
                          p_lssv_rec.jtot_object_code);
    FETCH okc_lssv_pk_csr INTO
              l_lssv_rec.LSE_ID,
              l_lssv_rec.JTOT_OBJECT_CODE,
              l_lssv_rec.OBJECT_VERSION_NUMBER,
              l_lssv_rec.ACCESS_LEVEL,
              l_lssv_rec.START_DATE,
              l_lssv_rec.END_DATE,
              l_lssv_rec.CREATED_BY,
              l_lssv_rec.CREATION_DATE,
              l_lssv_rec.LAST_UPDATED_BY,
              l_lssv_rec.LAST_UPDATE_DATE,
              l_lssv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_lssv_pk_csr%NOTFOUND;
    CLOSE okc_lssv_pk_csr;
    RETURN(l_lssv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_lssv_rec                     IN lssv_rec_type
  ) RETURN lssv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lssv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_LINE_STYLE_SOURCES_V --
  --------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_lssv_rec	IN lssv_rec_type
  ) RETURN lssv_rec_type IS
    l_lssv_rec	lssv_rec_type := p_lssv_rec;
  BEGIN
    IF (l_lssv_rec.lse_id = OKC_API.G_MISS_NUM) THEN
      l_lssv_rec.lse_id := NULL;
    END IF;
    IF (l_lssv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_lssv_rec.object_version_number := NULL;
    END IF;
    IF (l_lssv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_lssv_rec.start_date := NULL;
    END IF;
    IF (l_lssv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_lssv_rec.end_date := NULL;
    END IF;
    IF (l_lssv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_lssv_rec.created_by := NULL;
    END IF;
    IF (l_lssv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_lssv_rec.creation_date := NULL;
    END IF;
    IF (l_lssv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_lssv_rec.last_updated_by := NULL;
    END IF;
    IF (l_lssv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_lssv_rec.last_update_date := NULL;
    END IF;
    IF (l_lssv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_lssv_rec.last_update_login := NULL;
    END IF;
    IF (l_lssv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_lssv_rec.access_level := NULL;
    END IF;
    RETURN(l_lssv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------------
  -- Validate_Attributes for:OKC_LINE_STYLE_SOURCES_V --
  ------------------------------------------------------
  --**** Change from TAPI Code---follow till end of change---------------


-- This function checks if the new range does not overlap any existing range for the given sources
-- of the given line_style i'e only one source is active at a time for a line style
--
-- Date: 08/10/2001 08:20am
-- The body fo following procedure was commented out to avoid an inherent bug.
-- The check will always fail!!!!!
--
-- Problem Corrected on 08/11/2001
--
  FUNCTION Validate_Date_RANGE (
    p_lssv_rec                     IN lssv_rec_type)
    RETURN VARCHAR2 IS
    l_date                       date:=OKC_API.G_MISS_DATE;
    l_end_date                   date:=OKC_API.G_MISS_DATE;
    x_return_status              VARCHAR2(1);
    l_excp_error                 EXCEPTION;
    l_row_found                   BOOLEAN:= FALSE;

   Cursor C1 is select start_date from okc_line_style_sources where lse_id=p_lssv_rec.lse_id
		   and end_date is null  and jtot_object_code<>p_lssv_rec.jtot_object_code;

    Cursor C2(p_date IN date) is select start_date,nvl(end_date,p_date+1)
		    from OKC_LINE_STYLE_SOURCES where
		     lse_id=p_lssv_rec.lse_id and jtot_object_code<>p_lssv_rec.jtot_object_code;

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('Validate_Date_RANGE');
       okc_debug.Log('100:entering Validate_Date_RANGE',1);
    END IF;

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

    If p_lssv_rec.end_date is null then
     IF (l_debug = 'Y') THEN
        okc_debug.Log('200:validate_date_range',1);
     END IF;

	   OPEN C1;
	   FETCH C1 into l_date;
           l_row_found := C1%FOUND;
            CLOSE C1;

   --- this is replaced by the if statement below
   /*   IF l_date = OKC_API.G_MISS_DATE then
          IF (l_debug = 'Y') THEN
             okc_debug.Log('300:validate_date_range',1);
          END IF;
      -- RAISE l_excp_error;  -- This is where it should have been!!!!

	  	 ELSE  IF p_lssv_rec.start_date>=l_date then   --this has been changed to check for the same date aswell
                                                           --for BUG #1932165
			l_date:=p_lssv_rec.start_date;
             IF (l_debug = 'Y') THEN
                okc_debug.Log('400:validate_date_range',1);
             END IF;
           RAISE l_excp_error;
           end if;

           -- RAISE l_excp_error; --misplaced command!!!!!!
           END IF;
  */
    -- when the current record's end date is null , if there is an existing source with end date as null then ..error
       IF(l_row_found) then
         RAISE l_excp_error;
       END IF;
     END IF;
    OPEN C2(p_lssv_rec.end_date);
    LOOP
        FETCH C2 into l_date,l_end_date;
		 EXIT WHEN C2%NOTFOUND;
		 If trunc(p_lssv_rec.start_date)>=trunc(l_date) and trunc(p_lssv_rec.start_date)<=trunc(l_end_date) then
		    l_date:=p_lssv_rec.start_date;
           IF (l_debug = 'Y') THEN
              okc_debug.Log('500:8validate_date_range',1);
           END IF;
   	    RAISE l_excp_error;
                 Elsif trunc(nvl(p_lssv_rec.end_date,l_end_date+1))>=trunc(l_date)
					 and trunc(nvl(p_lssv_rec.end_date,l_end_date+1))<=trunc(l_end_date) then
		    l_date:=nvl(p_lssv_rec.end_date,l_end_date);
	 IF (l_debug = 'Y') THEN
   	 okc_debug.Log('500:validate_date_range',1);
	 END IF;
                  RAISE l_excp_error;
                 ElsIf trunc(l_date)>=trunc(p_lssv_rec.start_date)
		                       and trunc(l_date)<=trunc(nvl(p_lssv_rec.end_date,l_end_date+1)) then
	 IF (l_debug = 'Y') THEN
   	 okc_debug.Log('600:validate_date_range',1);
	 END IF;
                 RAISE l_excp_error;
		 ElsIf trunc(l_end_date)>=trunc(p_lssv_rec.start_date)
		                       and trunc(l_end_date)<=trunc(nvl(p_lssv_rec.end_date,l_end_date+1)) then
		    l_date:=l_end_date;
 IF (l_debug = 'Y') THEN
    okc_debug.Log('700:validate_date_range',1);
 END IF;
	    RAISE l_excp_error;
        END IF;
	   END LOOP;
    CLOSE C2;
   return x_return_status;
  EXCEPTION
    WHEN l_excp_error then
             IF (l_debug = 'Y') THEN
                okc_debug.Log('800:validate_date_range',1);
             END IF;
            x_return_status:=OKC_API.G_RET_STS_ERROR;
			IF C2%ISOPEN then
			    CLOSE C2;
	          END IF;
            OKC_API.set_message(G_APP_NAME, G_TOO_MANY_SOURCES,'DATE',
			  fnd_date.date_to_chardate(l_date)
			  ,'SOURCE','OKC_LINE_STYLE_SOURCES');
             return x_return_status;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
       IF (l_debug = 'Y') THEN
          okc_debug.Log('800:validate_date_range',1);
       END IF;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'START_DATE',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		IF C2%ISOPEN then
		    CLOSE C2;
	     END IF;
	  return x_return_status;
  IF (l_debug = 'Y') THEN
     okc_debug.reset_indentation;
  END IF;
  END ValidAte_DATE_RANGE;

--this is the old style range check. Was failing in case given start date and end date were the one
--not covered in any range individually. Changed with the above code
  FUNCTION Validate_Date_RANGE1 (
    p_lssv_rec                     IN lssv_rec_type)
    RETURN VARCHAR2 IS
    l_date                       date:=OKC_API.G_MISS_DATE;
    x_return_status              VARCHAR2(1);
    l_excp_error                 EXCEPTION;
    Cursor C1 is select start_date from okc_line_style_sources where lse_id=p_lssv_rec.lse_id
		   and end_date is null;

    Cursor C2(p_date IN date) is select p_date from OKC_LINE_STYLE_SOURCES where
		  lse_id=p_lssv_rec.lse_id and jtot_object_code<>p_lssv_rec.jtot_object_code and
		  trunc(p_date) between trunc(start_date) and trunc(nvl(end_date,p_date));

    Cursor C3(p_date IN date) is select start_date from OKC_LINE_STYLE_SOURCES where
		  lse_id=p_lssv_rec.lse_id and jtot_object_code<>p_lssv_rec.jtot_object_code and
		  trunc(start_date) between trunc(p_date) and trunc(end_date);
  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If p_lssv_rec.end_date is null then
	   OPEN C1;
	   FETCH C1 into l_date;
	   CLOSE C1;
	   IF l_date<>OKC_API.G_MISS_DATE then
		   IF p_lssv_rec.start_date>l_date then
			l_date:=p_lssv_rec.start_date;
	        end if;
             RAISE l_excp_error;
        END IF;
    END IF;
    OPEN C2(p_lssv_rec.start_date);
    FETCH C2 into l_date;
    CLOSE C2;
    IF l_date<>OKC_API.G_MISS_DATE then
        RAISE l_excp_error;
    END IF;
    IF p_lssv_rec.end_date is  null then
       OPEN C3(p_lssv_rec.start_date);
       FETCH C3 into l_date;
       CLOSE C3;
       IF l_date<>OKC_API.G_MISS_DATE then
        RAISE l_excp_error;
       END IF;
     ELSE
          OPEN C2(p_lssv_rec.end_date);
          FETCH C2 into l_date;
          CLOSE C2;
          IF l_date<>OKC_API.G_MISS_DATE then
              RAISE l_excp_error;
          END IF;
    END IF;
   return x_return_status;
   --return 'E';
  EXCEPTION
    WHEN l_excp_error then
            x_return_status:=OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message(G_APP_NAME, G_TOO_MANY_SOURCES,'DATE',
			  fnd_date.date_to_chardate(l_date)
			  ,'SOURCE','OKC_LINE_STYLE_SOURCES');
             return x_return_status;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'START_DATE',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	  return x_return_status;
  END Validate_DATE_RANGE1;

  PROCEDURE Validate_Start_Date (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_lssv_rec.start_date = OKC_API.G_MISS_DATE OR
        p_lssv_rec.start_date IS NULL) THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'START_DATE',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Start_Date;
--
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_ACCESS_LEVEL
  ---------------------------------------------------------------------------
PROCEDURE validate_access_level(
          p_lssv_rec      IN    lssv_rec_type,
          x_return_status 	OUT NOCOPY VARCHAR2) IS
  Begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_lssv_rec.access_level <> OKC_API.G_MISS_CHAR and
  	   p_lssv_rec.access_level IS NOT NULL)
    Then
       If p_lssv_rec.access_level NOT IN ('S','E', 'U') Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
				 p_msg_name	=> g_invalid_value,
				 p_token1	=> g_col_name_token,
				 p_token1_value	=> 'access_level');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
	     raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End validate_access_level;
--
--
  PROCEDURE Validate_lse_id (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_lssv_rec                     IN lssv_rec_type) IS
      l_excp_halt_validation         EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR lse_pk_csr (p_lse_id IN number) IS
      SELECT  lty_code
        FROM OKC_LINE_STYLES_B
       WHERE id        = p_lse_id;
      l_lse_pk                  lse_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_lssv_rec.lse_id IS NOT NULL AND
          p_lssv_rec.lse_id <> OKC_API.G_MISS_NUM)
      THEN
        OPEN lse_pk_csr(p_lssv_rec.lse_id);
        FETCH lse_pk_csr INTO l_lse_pk;
        l_row_notfound := lse_pk_csr%NOTFOUND;
        CLOSE lse_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'lse_id');
          RAISE l_excp_halt_validation;
        ELSE
		 IF l_lse_pk.lty_code='FREE_FORM' then
               OKC_API.set_message(G_APP_NAME,'OKC_NO_SRC_FOR_FREE');
               RAISE l_excp_halt_validation;
           END IF;
        END IF;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lse_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN l_excp_halt_validation THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'lse_id',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_lse_id ;

  PROCEDURE Validate_JTOT_Object_Code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type) IS
    item_not_found_error          EXCEPTION;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR jtot_pk_csr (p_jtot_object_code JTF_OBJECTS_B.object_code%type) IS
      SELECT '1'
        FROM JTF_OBJECTS_B a,jtf_object_usages b
       WHERE a.object_code = p_jtot_object_code
		   and sysdate between nvl(a.start_date_active,sysdate) and nvl(a.end_date_active,sysdate)
		   and a.object_code=b.object_code and b.object_user_code='OKX_LINES';
    l_jtot_pk                  jtot_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_lssv_rec.JTOT_OBJECT_CODE IS NOT NULL AND
          p_lssv_rec.JTOT_OBJECT_CODE <> OKC_API.G_MISS_CHAR)
      THEN
        OPEN jtot_pk_csr(p_lssv_rec.jtot_object_code);
        FETCH jtot_pk_csr INTO l_jtot_pk;
        l_row_notfound := jtot_pk_csr%NOTFOUND;
        CLOSE jtot_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'jtot_object_code');
          RAISE item_not_found_error;
        END IF;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'jtot_object_code');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'JTOT_OBJECT_CODE',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_JTOT_Object_Code;


   PROCEDURE Validate_Object_Code_item_t_pr(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type) IS
     l_item_to_price_yn            VARCHAR2(3):=NULL;
    l_object_user_code            VARCHAR2(30):=NULL;
    l_mtl_found                   BOOLEAN := FALSE;
    CURSOR loc_source_csr is
    select OBJECT_USER_CODE
     from JTF_OBJECT_USAGES where
       OBJECT_CODE = p_lssv_rec.JTOT_OBJECT_CODE
        AND OBJECT_USER_CODE = 'OKX_MTL_SYSTEM_ITEM';

   BEGIN
       Select item_to_price_yn into l_item_to_price_yn from OKC_LINE_STYLES_B
       where id = p_lssv_rec.lse_id;
      IF  sysdate between  p_lssv_rec.START_DATE and nvl( p_lssv_rec.END_DATE,sysdate) THEN
         IF l_item_to_price_yn = 'Y'
          THEN
           open loc_source_csr;
           Fetch loc_source_csr into l_object_user_code;
           l_mtl_found := loc_source_csr%FOUND;
           Close loc_source_csr;

             IF NOT l_mtl_found THEN
                 x_return_status := OKC_API.G_RET_STS_ERROR;
               OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  => 'OKC_ITEM_TO_PRICE_SOURCE');

             END IF;
             IF l_mtl_found THEN
                x_return_status := OKC_API.G_RET_STS_SUCCESS;
             END IF;
          ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
         END IF;
      ELSE
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
     END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

      WHEN OTHERS THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Validate_Object_Code_item_t_pr;
  FUNCTION Validate_Attributes (
    p_lssv_rec IN  lssv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_lssv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_lssv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    Validate_jtot_object_code (l_return_status,
                               p_lssv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_lse_id (l_return_status,
                     p_lssv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_object_code_item_t_pr (l_return_status,
                     p_lssv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
         END IF;
    END IF;
--
    Validate_access_level (p_lssv_rec,
                           l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
         END IF;
    END IF;

--
    Validate_start_date (l_return_status,
                     p_lssv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
	 END IF;
    END IF;

    RETURN(x_return_status);

  EXCEPTION
      When G_EXCEPTION_HALT_VALIDATION then
	    --just come out with return status
	     RETURN(x_return_status);
	   -- other appropriate handlers
	 When others then
	  -- store SQL error message on message stack
	     OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
						p_msg_name     => G_UNEXPECTED_ERROR,
	  				     p_token1       => G_SQLCODE_TOKEN,
					     p_token1_value => sqlcode,
						p_token2       => G_SQLERRM_TOKEN,
						p_token2_value => sqlerrm);
        --notify  UNEXPECTED error
		 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		 RETURN(x_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKC_LINE_STYLE_SOURCES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_lssv_rec IN lssv_rec_type
  ) RETURN VARCHAR2 IS

   -- ------------------------------------------------------
   -- To check for any matching row, for unique combination.
   -- ------------------------------------------------------
	 CURSOR cur_lss IS
	 SELECT 'x'
	 FROM   okc_line_style_sources
	 WHERE  lse_id           = p_lssv_rec.LSE_ID
	 AND    jtot_object_code = p_lssv_rec.JTOT_OBJECT_CODE;


         CURSOR cur_lss_1 IS
         SELECT 'x'
         FROM   okc_line_style_sources
         WHERE  lse_id           = p_lssv_rec.LSE_ID;


  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_row_found       BOOLEAN     := FALSE;
  l_dummy           VARCHAR2(1);
  BEGIN

IF (l_debug = 'Y') THEN
   okc_debug.set_indentation('Validate_Record');
   okc_debug.log('in validate_record',1);
END IF;
    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call is replaced with
    -- the explicit cursors above, for identical function to check
    -- uniqueness for LSE_ID + JTOT_OBJECT_CODE in OKC_LINE_STYLE_SOURCES_V
    -- ---------------------------------------------------------------------
    IF G_RECORD_STATUS = 'I' THEN
IF (l_debug = 'Y') THEN
   okc_debug.log('100:invalidate_record',1);
END IF;
      IF (        (p_lssv_rec.LSE_ID IS NOT NULL)
	       	AND (p_lssv_rec.LSE_ID <> OKC_API.G_MISS_NUM)    )
           AND
           (        (p_lssv_rec.JTOT_OBJECT_CODE IS NOT NULL)
		AND (p_lssv_rec.JTOT_OBJECT_CODE <> OKC_API.G_MISS_CHAR) )
        THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('200:invalidate_record',1);
      END IF;
            OPEN  cur_lss;
	    FETCH cur_lss INTO l_dummy;
	    l_row_found := cur_lss%FOUND;
            CLOSE cur_lss;

            IF (l_row_found)
	       THEN

IF (l_debug = 'Y') THEN
   okc_debug.log('300:invalidate_record',1);
END IF;

 		      -- Display the newly defined error message
		      OKC_API.set_message(G_APP_NAME,
		                          'OKC_DUP_LINE_STYLE_SOURCE');
                l_return_status := OKC_API.G_RET_STS_ERROR;


           -- the following code added for BUG#1932165 to call the validate_date_range when there is an
          --  existing line style source with end date = null
              ELSE
               IF (l_debug = 'Y') THEN
                  okc_debug.log('005:invalidate_record',1);
               END IF;
               OPEN  cur_lss_1;
            FETCH cur_lss_1 INTO l_dummy;
            l_row_found := cur_lss_1%FOUND;
            CLOSE cur_lss_1;
              IF (l_row_found)
               THEN
              IF (l_debug = 'Y') THEN
                 okc_debug.log('006:invalidate_record',1);
              END IF;
                l_return_status:=VALIDATE_DATE_RANGE(p_lssv_rec);
              END IF;
           END IF;

 	       return (l_return_status);
      END IF;
    END IF;

    IF (      (p_lssv_rec.start_date > p_lssv_rec.end_date)
          AND (p_lssv_rec.end_date  IS NOT NULL
	  AND  p_lssv_rec.end_date  <> OKC_API.G_MISS_DATE ))
    THEN
        IF (l_debug = 'Y') THEN
           okc_debug.log('400:invalidate_record',1);
        END IF;

           OKC_API.set_message(G_APP_NAME,
			      G_INVALID_VALUE,
			      G_COL_NAME_TOKEN,
			     'Start Date > End Date');
          l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSE
                IF (l_debug = 'Y') THEN
                   okc_debug.log('500:invalidate_record',1);
                END IF;

	     l_return_status:=VALIDATE_DATE_RANGE(p_lssv_rec);
    END IF;
    RETURN (l_return_status);
IF (l_debug = 'Y') THEN
   okc_debug.reset_indentation;
END IF;
  END Validate_Record;

  --**** end of change-------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN lssv_rec_type,
    p_to	IN OUT NOCOPY lss_rec_type
  ) IS
  BEGIN
    p_to.lse_id := p_from.lse_id;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.end_date := p_from.end_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN lss_rec_type,
    p_to	IN OUT NOCOPY lssv_rec_type
  ) IS
  BEGIN
    p_to.lse_id := p_from.lse_id;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.start_date := p_from.start_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.end_date := p_from.end_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.access_level := p_from.access_level;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- validate_row for:OKC_LINE_STYLE_SOURCES_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lssv_rec                     lssv_rec_type := p_lssv_rec;
    l_lss_rec                      lss_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_lssv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_lssv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:LSSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lssv_tbl.COUNT > 0) THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lssv_rec                     => p_lssv_tbl(i));
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- insert_row for:OKC_LINE_STYLE_SOURCES --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lss_rec                      IN lss_rec_type,
    x_lss_rec                      OUT NOCOPY lss_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lss_rec                      lss_rec_type := p_lss_rec;
    l_def_lss_rec                  lss_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLE_SOURCES --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_lss_rec IN  lss_rec_type,
      x_lss_rec OUT NOCOPY lss_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lss_rec := p_lss_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.set_indentation('insert_row');
     okc_debug.log('100:inside insert row',1 );
  END IF;
 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_lss_rec,                         -- IN
      l_lss_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_LINE_STYLE_SOURCES(
        lse_id,
        jtot_object_code,
        start_date,
        object_version_number,
        access_level,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        end_date,
        last_update_login)
      VALUES (
        l_lss_rec.lse_id,
        l_lss_rec.jtot_object_code,
        l_lss_rec.start_date,
        l_lss_rec.object_version_number,
        l_lss_rec.access_level,
        l_lss_rec.created_by,
        l_lss_rec.creation_date,
        l_lss_rec.last_updated_by,
        l_lss_rec.last_update_date,
        l_lss_rec.end_date,
        l_lss_rec.last_update_login);
    -- Set OUT values
    x_lss_rec := l_lss_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
   IF (l_debug = 'Y') THEN
      okc_debug.reset_indentation;
   END IF;
   END insert_row;
  ---------------------------------------------
  -- insert_row for:OKC_LINE_STYLE_SOURCES_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type,
    x_lssv_rec                     OUT NOCOPY lssv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lssv_rec                     lssv_rec_type;
    l_def_lssv_rec                 lssv_rec_type;
    l_lss_rec                      lss_rec_type;
    lx_lss_rec                     lss_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lssv_rec	IN lssv_rec_type
    ) RETURN lssv_rec_type IS
      l_lssv_rec	lssv_rec_type := p_lssv_rec;
    BEGIN
      l_lssv_rec.CREATION_DATE := SYSDATE;
      l_lssv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_lssv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_lssv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_lssv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_lssv_rec);
    END fill_who_columns;
    -------------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLE_SOURCES_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_lssv_rec IN  lssv_rec_type,
      x_lssv_rec OUT NOCOPY lssv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lssv_rec := p_lssv_rec;
      x_lssv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_lssv_rec := null_out_defaults(p_lssv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_lssv_rec,                        -- IN
      l_def_lssv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_lssv_rec := fill_who_columns(l_def_lssv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lssv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  --**** uniqueness is checked only in insert cases--------------------
    G_RECORD_STATUS := 'I';
    l_return_status := Validate_Record(l_def_lssv_rec);
    G_RECORD_STATUS := OKC_API.G_MISS_CHAR;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_lssv_rec, l_lss_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lss_rec,
      lx_lss_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lss_rec, l_def_lssv_rec);
    -- Set OUT values
    x_lssv_rec := l_def_lssv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:LSSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type,
    x_lssv_tbl                     OUT NOCOPY lssv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lssv_tbl.COUNT > 0) THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lssv_rec                     => p_lssv_tbl(i),
          x_lssv_rec                     => x_lssv_tbl(i));
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- lock_row for:OKC_LINE_STYLE_SOURCES --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lss_rec                      IN lss_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_lss_rec IN lss_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_LINE_STYLE_SOURCES
     WHERE LSE_ID = p_lss_rec.lse_id
       AND JTOT_OBJECT_CODE = p_lss_rec.jtot_object_code
       AND OBJECT_VERSION_NUMBER = p_lss_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_lss_rec IN lss_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_LINE_STYLE_SOURCES
    WHERE LSE_ID = p_lss_rec.lse_id
       AND JTOT_OBJECT_CODE = p_lss_rec.jtot_object_code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_LINE_STYLE_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_LINE_STYLE_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_lss_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_lss_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_lss_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_lss_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------------
  -- lock_row for:OKC_LINE_STYLE_SOURCES_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lss_rec                      lss_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_lssv_rec, l_lss_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lss_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:LSSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lssv_tbl.COUNT > 0) THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lssv_rec                     => p_lssv_tbl(i));
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- update_row for:OKC_LINE_STYLE_SOURCES --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lss_rec                      IN lss_rec_type,
    x_lss_rec                      OUT NOCOPY lss_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lss_rec                      lss_rec_type := p_lss_rec;
    l_def_lss_rec                  lss_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lss_rec	IN lss_rec_type,
      x_lss_rec	OUT NOCOPY lss_rec_type
    ) RETURN VARCHAR2 IS
      l_lss_rec                      lss_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lss_rec := p_lss_rec;
      -- Get current database values
      l_lss_rec := get_rec(p_lss_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_lss_rec.lse_id = OKC_API.G_MISS_NUM)
      THEN
        x_lss_rec.lse_id := l_lss_rec.lse_id;
      END IF;
      IF (x_lss_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lss_rec.jtot_object_code := l_lss_rec.jtot_object_code;
      END IF;
      IF (x_lss_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_lss_rec.start_date := l_lss_rec.start_date;
      END IF;
      IF (x_lss_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_lss_rec.object_version_number := l_lss_rec.object_version_number;
      END IF;
      IF (x_lss_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_lss_rec.created_by := l_lss_rec.created_by;
      END IF;
      IF (x_lss_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_lss_rec.creation_date := l_lss_rec.creation_date;
      END IF;
      IF (x_lss_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_lss_rec.last_updated_by := l_lss_rec.last_updated_by;
      END IF;
      IF (x_lss_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_lss_rec.last_update_date := l_lss_rec.last_update_date;
      END IF;
      IF (x_lss_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_lss_rec.end_date := l_lss_rec.end_date;
      END IF;
      IF (x_lss_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_lss_rec.last_update_login := l_lss_rec.last_update_login;
      END IF;
      IF (x_lss_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_lss_rec.access_level := l_lss_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLE_SOURCES --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_lss_rec IN  lss_rec_type,
      x_lss_rec OUT NOCOPY lss_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lss_rec := p_lss_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
   IF (l_debug = 'Y') THEN
      okc_debug.set_indentation('update_row');
      okc_debug.log('200:in update row',1);
   END IF;
   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_lss_rec,                         -- IN
      l_lss_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lss_rec, l_def_lss_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_LINE_STYLE_SOURCES
    SET START_DATE = l_def_lss_rec.start_date,
        OBJECT_VERSION_NUMBER = l_def_lss_rec.object_version_number,
        CREATED_BY = l_def_lss_rec.created_by,
        CREATION_DATE = l_def_lss_rec.creation_date,
        LAST_UPDATED_BY = l_def_lss_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_lss_rec.last_update_date,
        END_DATE = l_def_lss_rec.end_date,
        LAST_UPDATE_LOGIN = l_def_lss_rec.last_update_login,
        ACCESS_LEVEL = l_def_lss_rec.access_level
    WHERE LSE_ID = l_def_lss_rec.lse_id
      AND JTOT_OBJECT_CODE = l_def_lss_rec.jtot_object_code;

    x_lss_rec := l_def_lss_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  IF (l_debug = 'Y') THEN
     okc_debug.reset_indentation;
  END IF;
  END update_row;
  ---------------------------------------------
  -- update_row for:OKC_LINE_STYLE_SOURCES_V --
  ---------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type,
    x_lssv_rec                     OUT NOCOPY lssv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lssv_rec                     lssv_rec_type := p_lssv_rec;
    l_def_lssv_rec                 lssv_rec_type;
    l_lss_rec                      lss_rec_type;
    lx_lss_rec                     lss_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lssv_rec	IN lssv_rec_type
    ) RETURN lssv_rec_type IS
      l_lssv_rec	lssv_rec_type := p_lssv_rec;
    BEGIN
      l_lssv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_lssv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_lssv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_lssv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lssv_rec	IN lssv_rec_type,
      x_lssv_rec	OUT NOCOPY lssv_rec_type
    ) RETURN VARCHAR2 IS
      l_lssv_rec                     lssv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lssv_rec := p_lssv_rec;
      -- Get current database values
      l_lssv_rec := get_rec(p_lssv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_lssv_rec.lse_id = OKC_API.G_MISS_NUM)
      THEN
        x_lssv_rec.lse_id := l_lssv_rec.lse_id;
      END IF;
      IF (x_lssv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lssv_rec.jtot_object_code := l_lssv_rec.jtot_object_code;
      END IF;
      IF (x_lssv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_lssv_rec.object_version_number := l_lssv_rec.object_version_number;
      END IF;
      IF (x_lssv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_lssv_rec.start_date := l_lssv_rec.start_date;
      END IF;
      IF (x_lssv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_lssv_rec.end_date := l_lssv_rec.end_date;
      END IF;
      IF (x_lssv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_lssv_rec.created_by := l_lssv_rec.created_by;
      END IF;
      IF (x_lssv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_lssv_rec.creation_date := l_lssv_rec.creation_date;
      END IF;
      IF (x_lssv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_lssv_rec.last_updated_by := l_lssv_rec.last_updated_by;
      END IF;
      IF (x_lssv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_lssv_rec.last_update_date := l_lssv_rec.last_update_date;
      END IF;
      IF (x_lssv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_lssv_rec.last_update_login := l_lssv_rec.last_update_login;
      END IF;
      IF (x_lssv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_lssv_rec.access_level := l_lssv_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLE_SOURCES_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_lssv_rec IN  lssv_rec_type,
      x_lssv_rec OUT NOCOPY lssv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lssv_rec := p_lssv_rec;
      x_lssv_rec.OBJECT_VERSION_NUMBER := NVL(x_lssv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_lssv_rec,                        -- IN
      l_lssv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lssv_rec, l_def_lssv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_lssv_rec := fill_who_columns(l_def_lssv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lssv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lssv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_lssv_rec, l_lss_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lss_rec,
      lx_lss_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lss_rec, l_def_lssv_rec);
    x_lssv_rec := l_def_lssv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:LSSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type,
    x_lssv_tbl                     OUT NOCOPY lssv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lssv_tbl.COUNT > 0) THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lssv_rec                     => p_lssv_tbl(i),
          x_lssv_rec                     => x_lssv_tbl(i));
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- delete_row for:OKC_LINE_STYLE_SOURCES --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lss_rec                      IN lss_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lss_rec                      lss_rec_type:= p_lss_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_LINE_STYLE_SOURCES
     WHERE LSE_ID = l_lss_rec.lse_id AND
JTOT_OBJECT_CODE = l_lss_rec.jtot_object_code;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------------------
  -- delete_row for:OKC_LINE_STYLE_SOURCES_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_rec                     IN lssv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lssv_rec                     lssv_rec_type := p_lssv_rec;
    l_lss_rec                      lss_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_lssv_rec, l_lss_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lss_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:LSSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lssv_tbl                     IN lssv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lssv_tbl.COUNT > 0) THEN
      i := p_lssv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lssv_rec                     => p_lssv_tbl(i));
        EXIT WHEN (i = p_lssv_tbl.LAST);
        i := p_lssv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKC_LSS_PVT;

/
