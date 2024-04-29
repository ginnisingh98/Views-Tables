--------------------------------------------------------
--  DDL for Package Body OKC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_UTIL" AS
/* $Header: OKCUTILB.pls 120.2.12010000.2 2010/08/09 06:23:44 spingali ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

   l_Null_Val_Exception  EXCEPTION;

  -- This is a body global variable storing the value of
  -- USERENV('LANG'). The value is cached into this variable so that
  -- calling functions do not have to hit the database to determine this
  -- value.

   g_user_id               NUMBER                           := OKC_API.G_MISS_NUM;
   g_resp_id               NUMBER                           := OKC_API.G_MISS_NUM;
   g_reset_access_flag     BOOLEAN                          := FALSE;
   g_reset_lang_flag       BOOLEAN                          := FALSE;
   g_reset_resp_flag       BOOLEAN                          := FALSE;
   g_userenv_lang          fnd_languages.language_code%TYPE;
   g_resp_access           okc_k_accesses.access_level%TYPE := OKC_API.G_MISS_CHAR;
   g_user_resource_id      okc_k_accesses.resource_id%TYPE  := OKC_API.G_MISS_NUM;
   g_scs_code              okc_k_headers_b.scs_code%TYPE    := OKC_API.G_MISS_CHAR;
   g_groups_processed      Boolean := False;

   TYPE sec_group_tbl IS TABLE OF okc_k_accesses.group_id%TYPE;
   g_sec_groups  sec_group_tbl;

   TYPE lenchk_rec_type  IS RECORD (
    VName                         VARCHAR2(30),
    CName                         VARCHAR2(30),
    CDType			  VARCHAR2(20),
    CLength                       number,
    CScale                        number);

   TYPE lenchk_tbl_type  IS TABLE OF  lenchk_rec_type
   INDEX by BINARY_INTEGER;

   G_lenchk_tbl    lenchk_tbl_type;
   G_SPECIAL_STR   constant VARCHAR2(3):='~*|';
   G_COL_NAME_TOKEN1         CONSTANT VARCHAR2(30):='COL_NAME1';
   G_COL_NAME_TOKEN2         CONSTANT VARCHAR2(30):='COL_NAME2';
   G_COL_NAME_TOKEN3         CONSTANT VARCHAR2(30):='COL_NAME3';
   G_COL_NAME_TOKEN4         CONSTANT VARCHAR2(30):='COL_NAME4';
   G_COL_NAME_TOKEN5         CONSTANT VARCHAR2(30):='COL_NAME5';
   G_COL_NAME_TOKEN6         CONSTANT VARCHAR2(30):='COL_NAME6';
   G_COL_NAME_TOKEN7         CONSTANT VARCHAR2(30):='COL_NAME7';
   G_COL_NAME_TOKEN8         CONSTANT VARCHAR2(30):='COL_NAME8';
   G_COL_NAME_TOKEN9         CONSTANT VARCHAR2(30):='COL_NAME9';
   G_COL_NAME_TOKEN0         CONSTANT VARCHAR2(30):='COL_NAME0';

----------------------------------------------------------------------------
--Function to decide to a descriptive flexfield should be displayed
--It will return 'Y' if at least one of the DFF segment is both enabled and displayed
--It will return 'N' otherwise
--p_api_version: standard input parameter for the API version
--p_init_msg_list: standard input parameter for initialize message or not, defaulted to False
--p_application_short_name: the three letter application short name, e.g. 'OKC'
--p_dff_name: the name of the descriptive flexfield, e.g., 'DELIVERABLES_FLEX'
----------------------------------------------------------------------------

   FUNCTION Dff_Displayed ( p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
                            p_application_short_name VARCHAR2,
                            p_dff_name VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER)
                            return VARCHAR2

   IS

    flexfield FND_DFLEX.dflex_r;
    flexinfo  FND_DFLEX.dflex_dr;
    contexts  FND_DFLEX.contexts_dr;
    i BINARY_INTEGER;
    segments  FND_DFLEX.segments_dr;

    l_module  CONSTANT VARCHAR2(3) := 'OKC';
    l_api_name CONSTANT VARCHAR2(30) := 'DFF_DISPLAYED';

    l_displayed_yes CONSTANT VARCHAR2(1) := 'Y';
    l_displayed_no CONSTANT VARCHAR2(1) := 'N';
    l_return_success CONSTANT VARCHAR2(1) := 'S';
    l_return_error  CONSTANT VARCHAR2(1) := 'E';

    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       okc_debug.Set_Indentation('OKC_UTIL');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_module||l_api_name,'Entered Dff_Displayed');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_module||l_api_name,'p_application_short_name' ||p_application_short_name);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_module||l_api_name,'p_dff_name' ||p_dff_name);
    END IF;


    FND_DFLEX.get_flexfield(p_application_short_name, p_dff_name, flexfield, flexinfo);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'=== FLEXFIELD INFO ===');
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'title=' || flexinfo.title);
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'table=' || flexinfo.table_name);
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'descr=' || flexinfo.description);
    END IF;

    FND_DFLEX.get_contexts(flexfield, contexts);
    FOR i IN 1 .. contexts.ncontexts LOOP
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'Processing context: ' || contexts.context_code(i) || ' - ' ||
			      contexts.context_description(i));
	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'=== SEGMENT INFO (for one context) ===');
    END IF;

    FND_DFLEX.get_segments(FND_DFLEX.make_context(flexfield, contexts.context_code(i)),
		                  segments,
		                  TRUE);
    FOR i IN 1 .. segments.nsegments LOOP

        IF(segments.is_displayed(i)) THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'This segments is displayed: ' || segments.segment_name(i));
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'Returning Y');
            END IF;

        x_return_status := l_return_success;
        RETURN l_displayed_yes;
        END IF;

    END LOOP; -- FOR i IN 1 .. segments.nsegments

    END LOOP; -- FOR i IN 1 .. contexts.ncontexts

    --After looping through all the segments, none are displayed
    --Returning false
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,l_module||l_api_name,'None of the segments are displayed.  Returning N');
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,l_module||l_api_name,'Leaving Dff_Displayed');
    END IF;

    x_return_status := l_return_success;
    RETURN l_displayed_no;

    EXCEPTION
    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_module||l_api_name,'leaving OKC_UTIL.Dff_Displayed with error');
       END IF;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(l_module,l_api_name);
      END IF;

      x_return_status := l_return_error;

      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_module||l_api_name,'x_msg_count: '||x_msg_count);
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_module||l_api_name,'x_msg_data: '||x_msg_data);
       END IF;

    END Dff_Displayed;


   Procedure Set_Connection_Context Is
   Begin
	If (g_user_id = OKC_API.G_MISS_NUM) Or
	   (g_user_id <> fnd_global.user_id) Then
       g_user_id := fnd_global.user_id;
	  g_reset_access_flag := True;
	  g_reset_lang_flag := True;
     End If;

	If (g_resp_id = OKC_API.G_MISS_NUM) Or
	   (g_resp_id <> fnd_global.resp_id) Then
       g_resp_id := fnd_global.resp_id;
	  g_reset_resp_flag := True;
     End If;
   End;

   Procedure  checknumlen(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN Number,
    x_return_status                OUT NOCOPY VARCHAR2,
    ind				   IN Number);

----------------------------------------------------------------------------
-- Function to add column token if column exists (private function)
----------------------------------------------------------------------------
Function Column_Exists(e boolean,val varchar2) return varchar2 IS
Begin
         If e then
               return val;
         else
               return null;
         end if;
end;

----------------------------------------------------------------------------
-- Function to add column name if column exists (private function)
----------------------------------------------------------------------------
Function Value_Exists(e unq_tbl_type,ind number) return varchar2 IS
Begin
         If e.count>=ind  then
               return e(ind).p_col_name;
         else
         --      return null;
		  return ' ';
         end if;
end;

/*   Procedure add_view populates the global table for checking lengths.
     x_return_status has  'S' if successful else 'E'
*/
----------------------------------------------------------------------------
-- Procedure to add a view for checking length into global table
----------------------------------------------------------------------------
Procedure  add_view(
    p_view_name                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS
   cursor av_csr is select  table_name,Column_Name ,data_type,data_length,NVL(data_precision,OKC_API.G_MISS_NUM)
        data_precision,NVL(data_scale,0) data_scale
        FROM  user_tab_columns
        WHERE table_name = UPPER( p_view_name) and (data_type='VARCHAR2' OR data_type='NUMBER');
    var1    av_csr%rowtype;
    i      number:=1;
    found   Boolean:=FALSE;
   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;
     i:=G_lenchk_tbl.First;
       If G_lenchk_tbl.Count>0 Then
          Loop
           if (UPPER(p_view_name)=UPPER(G_lenchk_tbl(i).vname)) Then
                         found:=TRUE;
                Exit;
           End if;
                 Exit when i=G_lenchk_tbl.Last;
                 i:=G_lenchk_tbl.Next(i);
         End Loop;
       End if;
    If NOT found Then
         OPEN av_csr;
         i:=G_lenchk_tbl.count;
        LOOP
         FETCH av_csr into var1;
         EXIT   WHEN   av_csr%NOTFOUND;
          i:=i+1;
          G_lenchk_tbl(i).vname:=var1.table_name;
          G_lenchk_tbl(i).cname:=var1.column_name;
                        G_lenchk_tbl(i).cdtype:=var1.data_type;
                        if var1.data_type='NUMBER' Then
                          G_lenchk_tbl(i).clength:=var1.data_precision;
                          G_lenchk_tbl(i).cscale:=var1.data_scale;
                        else
                           G_lenchk_tbl(i).clength:=var1.data_length;
                        end if;
        END LOOP;
        If av_csr%ROWCOUNT<1 Then
	     x_return_status:=OKC_API.G_RET_STS_ERROR;
             OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			         p_msg_name      =>  G_NOTFOUND,
                                 p_token1        =>  G_VIEW_TOKEN,
			         p_token1_value  =>  UPPER(p_view_name));

        End If;

        CLOSE av_csr;
    End If;

 Exception
        when others then
          x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
          OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_UNEXPECTED_ERROR,
                              p_token1        =>  G_SQLCODE_TOKEN,
			      p_token1_value  =>  sqlcode,
                              p_token2        =>  G_SQLERRM_TOKEN,
			      p_token2_value  =>  sqlerrm);

End add_view;
/*   Procedure check_length checks the length of the passed in value of column
     x_return_status has  'S' if length is less than or equal to maximum length for that column
     x_return_status has  'E' if length is more than  maximum length for that column
     x_return_status has  'U' if it cannot find the column in the global table populated trough add_view
*/
----------------------------------------------------------------------------
--  checks length of a varchar2 column
----------------------------------------------------------------------------
Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    i number:=0;
    col_len number:=0;
   Begin
         x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
         i:=G_lenchk_tbl.First;
         Loop
          if ((UPPER(p_view_name)=UPPER(G_lenchk_tbl(i).vname)) and
              (UPPER(p_col_name)=UPPER(G_lenchk_tbl(i).cname)) ) Then
               If  (UPPER(G_lenchk_tbl(i).cdtype)='VARCHAR2') Then
                      col_len:=nvl(length(p_col_value),0);
                      if col_len<=TRUNC((G_lenchk_tbl(i).CLength)/3) then
                            x_return_status:=OKC_API.G_RET_STS_SUCCESS;
                      else
                            x_return_status:= OKC_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                        p_msg_name      =>  G_LEN_CHK,
                                                p_token1        =>  G_COL_NAME_TOKEN,
			                        p_token1_value  =>  p_col_name,
                                                p_token2        =>  'COL_LEN',
			                        p_token2_value  =>  '('||trunc((G_lenchk_tbl(i).clength)/3)||')');
                      end if;
               ElsIf (UPPER(G_lenchk_tbl(i).cdtype)='NUMBER') Then
	               checknumlen(p_view_name,p_col_name,to_number(p_col_value),x_return_status,i);

               End If;
               Exit;
           End if;
           Exit when i=G_lenchk_tbl.Last;
           i:=G_lenchk_tbl.Next(i);
         End Loop;

         EXCEPTION
         when others then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNEXPECTED_ERROR,
                                    p_token1        =>  G_SQLCODE_TOKEN,
			            p_token1_value  =>  sqlcode,
                                    p_token2        =>  G_SQLERRM_TOKEN,
			            p_token2_value  =>  sqlerrm);
End check_length;

----------------------------------------------------------------------------
--  checks length of a number column (private procedure)
----------------------------------------------------------------------------
Procedure  checknumlen(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN Number,
    x_return_status                OUT NOCOPY VARCHAR2,
    ind        IN Number) IS
    i     Number:=ind;
    l_pre    Number :=0;
    l_scale   Number :=0;
    l_str_pos   Varchar2(40):='';
    l_pos    Number :=0;
    l_neg    Number :=0;
    l_value  Number :=0;
    l_val    varchar2(64):='.';
    cursor c1 is select value from v$nls_parameters where parameter='NLS_NUMERIC_CHARACTERS';
   Begin
   -- get the character specified for decimal right now in the database
      open c1;
      fetch c1 into l_val;
      close c1;
         x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
         l_value:=NVL(p_col_value,0);
	    IF (G_lenchk_tbl(i).clength=OKC_API.G_MISS_NUM) Then
                     x_return_status:=OKC_API.G_RET_STS_SUCCESS;
         ELSE
             l_pre:=G_lenchk_tbl(i).clength-ABS(G_lenchk_tbl(i).cscale);
             for j in 1..l_pre loop
                 l_str_pos:=l_str_pos||'9';
             end loop;
             l_scale:=G_lenchk_tbl(i).cscale;
             If (l_scale>0) Then
     	    	    --l_str_pos:=l_str_pos||'.';
     	    	    l_str_pos:=l_str_pos||substr(l_val,1,1);
      		    for j in 1..l_scale loop
                          l_str_pos:=l_str_pos||'9';
       		    end loop;
             ElsIf (l_scale<0) Then
      		    for j in 1..ABS(l_scale) loop
                          l_str_pos:=l_str_pos||'0';
       		    end loop;
     	    end if;
            l_pos:=to_number(l_str_pos);
            l_neg:=(-1)*l_pos;
            if l_value<=l_pos and l_value>=l_neg then
                 x_return_status:=OKC_API.G_RET_STS_SUCCESS;
            else
                 x_return_status:=OKC_API.G_RET_STS_ERROR;
                 OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			             p_msg_name      =>  G_LEN_CHK,
                                     p_token1        =>  G_COL_NAME_TOKEN,
			             p_token1_value  =>  p_col_name);
            end if;
         End If;
        EXCEPTION
           when others then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNEXPECTED_ERROR,
                                    p_token1        =>  G_SQLCODE_TOKEN,
			            p_token1_value  =>  sqlcode,
                                    p_token2        =>  G_SQLERRM_TOKEN,
			            p_token2_value  =>  sqlerrm);
End checknumlen;

----------------------------------------------------------------------------
--  checks length of a number column
----------------------------------------------------------------------------
Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2) IS
   Begin
         check_length(p_view_name,p_col_name, to_char(p_col_value) , x_return_status);
End check_length;


/*---------------------------------------------------------------------------+
The procedure check_unique checks for uniqueness of the p_col_value passed.
It returns
OKC_API.G_RET_STS_SUCCESS if the p_col_value being passed is
 unique that is not already in view p_view_name
OKC_API.G_RET_STS_ERROR If the p_col_value being passed is
 not unique that is already in view p_view_name
OKC_API.G_RET_STS_UNEXP_ERROR If there is some unexpected error in processing
*-------------------------------------------------------------------------- */

----------------------------------------------------------------------------
 --checks uniqnuess of varchar2 when primary key is ID
----------------------------------------------------------------------------
Procedure  Check_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;
    l_query                VARCHAR2(1000);
    l_id                   Number:=OKC_API.G_MISS_NUM;

   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;
        IF (p_col_value is NULL) Then
                    RAISE l_Null_Val_Exception;
        End If;

	--form query
        --l_query:='select ''1'' from ' || p_view_name || ' where ' || p_col_name || ' =:l_value and id <>l_id' ;
         l_query:='select id  from ' || p_view_name || ' where ' || p_col_name || ' =:l_value' ;
	--Execute query
	/*EXECUTE IMMEDIATE l_query INTO l_COUNT
          USING  p_col_value,p_id;*/

        OPEN  unq_csr FOR l_query
             USING  p_col_value;
        FETCH unq_csr into l_id;
        Close unq_csr;

        IF (l_id<>OKC_API.G_MISS_NUM AND l_id<>nvl(p_id,0)) THEN
		x_return_status:=OKC_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNQ,
                                    p_token1        =>  G_COL_NAME_TOKEN ,
			            p_token1_value  =>  p_col_name);
        END IF;

       EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_NVL,
                                	   p_token1        =>  G_COL_NAME_TOKEN,
			                   p_token1_value  =>  p_col_name);


       	    WHEN others then
                        x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                    p_msg_name      =>  G_UNEXPECTED_ERROR,
                                            p_token1        =>  G_SQLCODE_TOKEN,
			                    p_token1_value  =>  sqlcode,
                                            p_token2        =>  G_SQLERRM_TOKEN,
			                    p_token2_value  =>  sqlerrm);
End Check_Unique;

----------------------------------------------------------------------------
  --checks uniquness of NUMBER when primary key is ID
----------------------------------------------------------------------------
Procedure  Check_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN NUMBER,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;
    l_query                VARCHAR2(1000);
    l_id                   Number:=OKC_API.G_MISS_NUM;

   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;
        IF (p_col_value is NULL) Then
                    RAISE l_Null_Val_Exception;
        End If;

	--form query
        --l_query:='select ''1'' from ' || p_view_name || ' where ' || p_col_name || ' =:l_value and id <>l_id' ;

        l_query:='select id from ' || p_view_name || ' where ' || p_col_name || ' =:l_value' ;

	--Execute query
	/*EXECUTE IMMEDIATE l_query INTO l_COUNT
          USING  p_col_value,p_id;*/

        OPEN  unq_csr FOR l_query
             USING  p_col_value;
        FETCH unq_csr into l_id;
        Close unq_csr;

        IF (l_id<>OKC_API.G_MISS_NUM AND l_id<>nvl(p_id,0)) THEN
		x_return_status:=OKC_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNQ,
                                    p_token1        =>  G_COL_NAME_TOKEN ,
			            p_token1_value  =>  p_col_name);
        END IF;

       EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_NVL,
                                	   p_token1        =>  G_COL_NAME_TOKEN,
			                   p_token1_value  =>  p_col_name);


       	    WHEN others then
                        x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                    p_msg_name      =>  G_UNEXPECTED_ERROR,
                                            p_token1        =>  G_SQLCODE_TOKEN,
			                    p_token1_value  =>  sqlcode,
                                            p_token2        =>  G_SQLERRM_TOKEN,
			                    p_token2_value  =>  sqlerrm);

End Check_Unique;

---------------------------------------------------------------------------
  --checks uniquness of DATE when primary key is ID
----------------------------------------------------------------------------
Procedure  Check_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN DATE,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    l_query                VARCHAR2(1000);
    l_id                   Number:=OKC_API.G_MISS_NUM;
    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;

   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;
        IF (p_col_value is NULL) Then
                    RAISE l_Null_Val_Exception;
        End If;

	--Form query
        l_query:='select id from ' || p_view_name || ' where trunc('  || p_col_name || ' ) =trunc(:l_value)';

	--Execute query
        OPEN  unq_csr FOR l_query
             USING  p_col_value;
        FETCH unq_csr into l_id;
        Close unq_csr;

        IF (l_id<>OKC_API.G_MISS_NUM AND l_id<>nvl(p_id,0)) THEN
		x_return_status:=OKC_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNQ,
                                    p_token1        =>  G_COL_NAME_TOKEN ,
			            p_token1_value  =>  p_col_name);

        END IF;

       EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_NVL,
                                	   p_token1        =>  G_COL_NAME_TOKEN,
			                   p_token1_value  =>  p_col_name);


       	    WHEN others then
                        x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                    p_msg_name      =>  G_UNEXPECTED_ERROR,
                                            p_token1        =>  G_SQLCODE_TOKEN,
			                    p_token1_value  =>  sqlcode,
                                            p_token2        =>  G_SQLERRM_TOKEN,
			                    p_token2_value  =>  sqlerrm);
End Check_Unique;

----------------------------------------------------------------------------
  --checks uniqueness of composite value made up of multiple columns when primary key is ID
----------------------------------------------------------------------------
Procedure  Check_Comp_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_tbl	                   IN unq_tbl_type,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    l_all_null             Boolean:= TRUE;
    l_query                VARCHAR2(3000);
    l_id                   Number:=OKC_API.G_MISS_NUM;
    l_ind   Number:=0;
    l_index Number:=1;
    l_cols  unq_tbl_type;
    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;

   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;

        l_query:='select id from ' || p_view_name || ' where ';

        If p_col_tbl.Count>0 Then
            l_ind:=p_col_tbl.FIRST;
            Loop
                IF (p_col_tbl(l_ind).p_col_val is NULL) Then
                    l_query:=l_query||p_col_tbl(l_ind).p_col_name||' is null';
                else
                    l_query:=l_query||p_col_tbl(l_ind).p_col_name||'='''||replace(p_col_tbl(l_ind).p_col_val,'''','''''')||'''';
                    l_all_null := FALSE;
                End If;
                l_cols(l_index).p_col_name:=p_col_tbl(l_ind).p_col_name;
                Exit when l_ind=p_col_tbl.Last;
                l_query:=l_query||' and ' ;
                l_ind:=p_col_tbl.Next(l_ind);
                l_index:=l_index+1;
            End Loop;

            If l_all_null Then
                    RAISE l_Null_Val_Exception;
            end if;

	     --Execute query
             OPEN  unq_csr FOR l_query;
             FETCH unq_csr into l_id;
             Close unq_csr;

             IF (l_id<>OKC_API.G_MISS_NUM AND l_id<>nvl(p_id,0)) THEN
		   x_return_status:=OKC_API.G_RET_STS_ERROR;
                   OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			               p_msg_name      =>  G_UNQS,
                                       p_token1        =>  G_COL_NAME_TOKEN1,
			               p_token1_value  =>  l_cols(1).p_col_name,
				       p_token2        =>  G_COL_NAME_TOKEN2,
			               p_token2_value  =>  Value_Exists(l_cols,2),
				       p_token3        =>  G_COL_NAME_TOKEN3,
			               p_token3_value  =>  Value_Exists(l_cols,3),
				       p_token4        =>  G_COL_NAME_TOKEN4,
			               p_token4_value  =>  Value_Exists(l_cols,4),
				       p_token5        =>  G_COL_NAME_TOKEN5,
			               p_token5_value  =>  Value_Exists(l_cols,5),
				       p_token6        =>  G_COL_NAME_TOKEN6,
			               p_token6_value  =>  Value_Exists(l_cols,6),
				       p_token7        =>  G_COL_NAME_TOKEN7,
			               p_token7_value  =>  Value_Exists(l_cols,7),
				       p_token8        =>  G_COL_NAME_TOKEN8,
			               p_token8_value  =>  Value_Exists(l_cols,8),
				       p_token9        =>  G_COL_NAME_TOKEN9,
			               p_token9_value  =>  Value_Exists(l_cols,9),
				       p_token10        => G_COL_NAME_TOKEN0,
			               p_token10_value  =>  Value_Exists(l_cols,10));
			    /*
                   OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			               p_msg_name      =>  G_UNQS,
                                       p_token1        =>  G_COL_NAME_TOKEN,
			               p_token1_value  =>  l_cols(1).p_col_name,
				       p_token2        =>  Column_Exists(l_cols.count>=2,G_COL_NAME_TOKEN),
			               p_token2_value  =>  Value_Exists(l_cols,2),
				       p_token3        =>  Column_Exists(l_cols.count>=3,G_COL_NAME_TOKEN),
			               p_token3_value  =>  Value_Exists(l_cols,3),
				       p_token4        =>  Column_Exists(l_cols.count>=4,G_COL_NAME_TOKEN),
			               p_token4_value  =>  Value_Exists(l_cols,4),
				       p_token5        =>  Column_Exists(l_cols.count>=5,G_COL_NAME_TOKEN),
			               p_token5_value  =>  Value_Exists(l_cols,5),
				       p_token6        =>  Column_Exists(l_cols.count>=6,G_COL_NAME_TOKEN),
			               p_token6_value  =>  Value_Exists(l_cols,6),
				       p_token7        =>  Column_Exists(l_cols.count>=7,G_COL_NAME_TOKEN),
			               p_token7_value  =>  Value_Exists(l_cols,7),
				       p_token8        =>  Column_Exists(l_cols.count>=8,G_COL_NAME_TOKEN),
			               p_token8_value  =>  Value_Exists(l_cols,8),
				       p_token9        =>  Column_Exists(l_cols.count>=9,G_COL_NAME_TOKEN),
			               p_token9_value  =>  Value_Exists(l_cols,9),
				       p_token10        =>  Column_Exists(l_cols.count>=10,G_COL_NAME_TOKEN),
			               p_token10_value  =>  Value_Exists(l_cols,10));

					 */

           END IF;

       End If;

         EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_ALL_NVL);

       	   WHEN OTHERS then
         		 x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
			     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                         p_msg_name      =>  G_UNEXPECTED_ERROR,
                                                 p_token1        =>  G_SQLCODE_TOKEN,
			                         p_token1_value  =>  sqlcode,
                                                 p_token2        =>  G_SQLERRM_TOKEN,
			                         p_token2_value  =>  sqlerrm);
End Check_Comp_Unique;



----------------------------------------------------------------------------
  --checks uniqueness of varchar2 when primary key is other than ID
----------------------------------------------------------------------------
Procedure  Check_Unique(
    p_table_name                   IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    p_primary                      IN unq_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;
    l_query                VARCHAR2(1000);

    l_pk_in_str    VARCHAR2(600);
    l_pk_cols      VARCHAR2(600);
    l_pk_selected_str    VARCHAR2(600):=G_SPECIAL_STR;
    l_column         VARCHAR2(50);
    l_ind               number:=0;

   Begin
        IF (p_col_value is NULL) Then
                    RAISE l_Null_Val_Exception;
        End If;
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;

        If p_primary.Count>0 Then
            l_ind:=p_primary.FIRST;
		  --make a string out of primary key values (l_pk_in_str)
		  --make a string to make part of the queries which will fetch the
		  --string of primary key values for which p_col_value is found(l_pk_cols)
            Loop
                l_pk_in_str:=l_pk_in_str||nvl(p_primary(l_ind).p_col_val,' ')||G_SPECIAL_STR;
                l_pk_cols  :=l_pk_cols||p_primary(l_ind).p_col_name||'||'''||G_SPECIAL_STR||'''';
                Exit when l_ind=p_primary.Last;
                l_pk_cols  :=l_pk_cols||'||';
                l_ind:=p_primary.Next(l_ind);

            End Loop;

           --form query
           l_query:='select ' || l_pk_cols||' from ' || p_table_name || ' where ' || p_col_name || ' =:l_value';

            -- Here assumption is that since the coulmn always has unique value
		  --hence only one record with p_col_value can be there in the database maximum.
            --Execute query
            OPEN  unq_csr FOR l_query
            USING  p_col_value;
            FETCH unq_csr into l_pk_selected_str;
            Close unq_csr;

            -- The value returned in l_pk_selected_str is either its original value
		  --since no record was found or the found value is same as the string of
		  --primary key values passed thru the record. If its neither case
		  --then the p_col_value exists for some other primary key value.
		  --hence error
            IF (l_pk_selected_str<>G_SPECIAL_STR AND l_pk_selected_str<>l_pk_in_str) THEN
                    x_return_status:=OKC_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                                        p_msg_name      =>  G_UNQ,
                                        p_token1        =>  G_COL_NAME_TOKEN ,
                                        p_token1_value  =>  p_col_name);

            END IF;
         END IF;

        EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                                           p_msg_name      =>  G_NVL,
                                           p_token1        =>  G_COL_NAME_TOKEN,
                                           p_token1_value  =>  p_col_name);


            WHEN OTHERS then
                        x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
                        OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                                            p_msg_name      =>  G_UNEXPECTED_ERROR,
                                            p_token1        =>  G_SQLCODE_TOKEN,
                                            p_token1_value  =>  sqlcode,
                                            p_token2        =>  G_SQLERRM_TOKEN,
                                            p_token2_value  =>  sqlerrm);
End Check_Unique;


----------------------------------------------------------------------------
  --checks uniqueness of NUMBER when primary key is other than ID
----------------------------------------------------------------------------
Procedure  Check_Unique(
    p_table_name                    IN VARCHAR2,
    p_col_name	                    IN VARCHAR2,
    p_col_value                     IN NUMBER,
    p_primary                      IN unq_tbl_type,
    x_return_status                 OUT NOCOPY VARCHAR2) IS
   Begin
        check_unique(p_table_name ,p_col_name,to_char(p_col_value),p_primary,x_return_status);
End Check_Unique;



----------------------------------------------------------------------------
  --checks uniqueness of varchar2 when primary key is other than ID
----------------------------------------------------------------------------
Procedure  Check_Unique(
    p_table_name                   IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN DATE,
    p_primary                      IN unq_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;
    l_query                VARCHAR2(1000);

    l_pk_in_str    VARCHAR2(600);
    l_pk_cols      VARCHAR2(600);
    l_pk_selected_str    VARCHAR2(600):=G_SPECIAL_STR;
    l_column         VARCHAR2(50);
    l_ind               number:=0;

   Begin
        IF (p_col_value is NULL) Then
                    RAISE l_Null_Val_Exception;
        End If;
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;

        If p_primary.Count>0 Then
            l_ind:=p_primary.FIRST;
		  --make a string out of primary key values (l_pk_in_str)
		  --make a string to make part of the query which will fetch the
		  --string of primary key values if p_col_value is found(l_pk_cols)
            Loop
                l_pk_in_str:=l_pk_in_str||nvl(p_primary(l_ind).p_col_val,' ')||G_SPECIAL_STR;
                l_pk_cols  :=l_pk_cols||p_primary(l_ind).p_col_name||'||'''||G_SPECIAL_STR||'''';
                Exit when l_ind=p_primary.Last;
                l_pk_cols  :=l_pk_cols||'||';
                l_ind:=p_primary.Next(l_ind);

            End Loop;

           --form query
           l_query:='select ' || l_pk_cols||' from ' || p_table_name || ' where trunc(' || p_col_name || ') =trunc(:l_value)';

            -- Here assumption is that since the coulmn always has unique value
		  --hence only one record with p_col_value can be there in the database maximum.
            --Execute query
            OPEN  unq_csr FOR l_query
            USING  p_col_value;
            FETCH unq_csr into l_pk_selected_str;
            Close unq_csr;

            -- The value returned in l_pk_selected_str is either its original value
		  --since no record was found or the found value is same as the string of
		  --primary key values passed thru the record. If its neither case
		  --then the p_col_value exists for some other primary key value.
		  --hence error
            IF (l_pk_selected_str<>G_SPECIAL_STR AND l_pk_selected_str<>l_pk_in_str) THEN
                    x_return_status:=OKC_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                                        p_msg_name      =>  G_UNQ,
                                        p_token1        =>  G_COL_NAME_TOKEN ,
                                        p_token1_value  =>  p_col_name);

            END IF;
         END IF;

        EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                                           p_msg_name      =>  G_NVL,
                                           p_token1        =>  G_COL_NAME_TOKEN,
                                           p_token1_value  =>  p_col_name);


            WHEN OTHERS then
                        x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
                        OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
                                            p_msg_name      =>  G_UNEXPECTED_ERROR,
                                            p_token1        =>  G_SQLCODE_TOKEN,
                                            p_token1_value  =>  sqlcode,
                                            p_token2        =>  G_SQLERRM_TOKEN,
                                            p_token2_value  =>  sqlerrm);
End Check_Unique;


----------------------------------------------------------------------------
  --checks uniqueness of composite value made up of multiple columns when primary key is other than ID
----------------------------------------------------------------------------
Procedure  Check_Comp_Unique(
    p_table_name                    IN VARCHAR2,
    p_col_tbl	                    IN unq_tbl_type,
    p_primary                       IN unq_tbl_type,
    x_return_status                 OUT NOCOPY VARCHAR2) IS



    l_pk_in_str    VARCHAR2(600);
    l_pk_cols      VARCHAR2(600);
    l_pk_selected_str    VARCHAR2(600):=G_SPECIAL_STR;


    l_query                VARCHAR2(3000);
    l_ind   Number:=0;
    l_index Number:=1;
    l_cols unq_tbl_type;

    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;
    l_all_null      Boolean :=TRUE;

   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;

        If p_primary.Count>0 Then
            l_ind:=p_primary.FIRST;
		  --make a string out of primary key values (l_pk_in_str)
		  --make a string to make part of the query which will fetch the
		  --string of primary key values if set of values is found(l_pk_cols)
            Loop
                l_pk_in_str:=l_pk_in_str||nvl(p_primary(l_ind).p_col_val,' ')||G_SPECIAL_STR;
                l_pk_cols  :=l_pk_cols||p_primary(l_ind).p_col_name||'||'''||G_SPECIAL_STR||'''';
                Exit when l_ind=p_primary.Last;
                l_pk_cols  :=l_pk_cols||'||';
                l_ind:=p_primary.Next(l_ind);

            End Loop;

       -- form next query
           l_query:='select ' || l_pk_cols||' from ' || p_table_name || ' where ';

        If p_col_tbl.Count>0 Then
            l_ind:=p_col_tbl.FIRST;
            Loop
                IF (p_col_tbl(l_ind).p_col_val is NULL) Then
                    l_query:=l_query||p_col_tbl(l_ind).p_col_name||' is null';
                else
                    l_query:=l_query||p_col_tbl(l_ind).p_col_name||'='''||replace(p_col_tbl(l_ind).p_col_val,'''','''''')||'''';
                    l_all_null := FALSE;
                End If;
                l_cols(l_index).p_col_name:=p_col_tbl(l_ind).p_col_name;
                Exit when l_ind=p_col_tbl.Last;
                l_query:=l_query||' and ' ;
                l_ind:=p_col_tbl.Next(l_ind);
                l_index:=l_index+1;
            End Loop;

            If l_all_null Then
                    RAISE l_Null_Val_Exception;
            End if;
            -- Here assumption is that since the set of coulmns always has unique value
		  --hence only one record with these values can be there in the database maximum.
	--Execute query
            OPEN  unq_csr FOR l_query;
            FETCH unq_csr into l_pk_selected_str;
            Close unq_csr;

            -- The value returned in l_pk_selected_str is either its original value
		  --since no record was found or the found value is same as the string of
		  --primary key values passed thru the record. If its neither case
		  --then the p_col_value exists for some other primary key value.
		  --hence error
            IF (l_pk_selected_str<>G_SPECIAL_STR AND l_pk_selected_str<>l_pk_in_str) THEN
                    x_return_status:=OKC_API.G_RET_STS_ERROR;
                   OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			               p_msg_name      =>  G_UNQS,
                                       p_token1        =>  G_COL_NAME_TOKEN1,
			               p_token1_value  =>  l_cols(1).p_col_name,
				       p_token2        =>  G_COL_NAME_TOKEN2,
			               p_token2_value  =>  Value_Exists(l_cols,2),
				       p_token3        =>  G_COL_NAME_TOKEN3,
			               p_token3_value  =>  Value_Exists(l_cols,3),
				       p_token4        =>  G_COL_NAME_TOKEN4,
			               p_token4_value  =>  Value_Exists(l_cols,4),
				       p_token5        =>  G_COL_NAME_TOKEN5,
			               p_token5_value  =>  Value_Exists(l_cols,5),
				       p_token6        =>  G_COL_NAME_TOKEN6,
			               p_token6_value  =>  Value_Exists(l_cols,6),
				       p_token7        =>  G_COL_NAME_TOKEN7,
			               p_token7_value  =>  Value_Exists(l_cols,7),
				       p_token8        =>  G_COL_NAME_TOKEN8,
			               p_token8_value  =>  Value_Exists(l_cols,8),
				       p_token9        =>  G_COL_NAME_TOKEN9,
			               p_token9_value  =>  Value_Exists(l_cols,9),
				       p_token10        => G_COL_NAME_TOKEN0,
			               p_token10_value  =>  Value_Exists(l_cols,10));
				/*
                   OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			               p_msg_name      =>  G_UNQS,
                                       p_token1        =>  G_COL_NAME_TOKEN,
			               p_token1_value  =>  l_cols(1).p_col_name,
				       p_token2        =>  Column_Exists(l_cols.count>=2,G_COL_NAME_TOKEN),
			               p_token2_value  =>  Value_Exists(l_cols,2),
				       p_token3        =>  Column_Exists(l_cols.count>=3,G_COL_NAME_TOKEN),
			               p_token3_value  =>  Value_Exists(l_cols,3),
				       p_token4        =>  Column_Exists(l_cols.count>=4,G_COL_NAME_TOKEN),
			               p_token4_value  =>  Value_Exists(l_cols,4),
				       p_token5        =>  Column_Exists(l_cols.count>=5,G_COL_NAME_TOKEN),
			               p_token5_value  =>  Value_Exists(l_cols,5),
				       p_token6        =>  Column_Exists(l_cols.count>=6,G_COL_NAME_TOKEN),
			               p_token6_value  =>  Value_Exists(l_cols,6),
				       p_token7        =>  Column_Exists(l_cols.count>=7,G_COL_NAME_TOKEN),
			               p_token7_value  =>  Value_Exists(l_cols,7),
				       p_token8        =>  Column_Exists(l_cols.count>=8,G_COL_NAME_TOKEN),
			               p_token8_value  =>  Value_Exists(l_cols,8),
				       p_token9        =>  Column_Exists(l_cols.count>=9,G_COL_NAME_TOKEN),
			               p_token9_value  =>  Value_Exists(l_cols,9),
				       p_token10        =>  Column_Exists(l_cols.count>=10,G_COL_NAME_TOKEN),
			               p_token10_value  =>  Value_Exists(l_cols,10));
						*/
           END IF;
        End If;
     End If;

         EXCEPTION
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_ALL_NVL);


            WHEN OTHERS then
         		 x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
			 OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                     p_msg_name      =>  G_UNEXPECTED_ERROR,
                                             p_token1        =>  G_SQLCODE_TOKEN,
			                     p_token1_value  =>  sqlcode,
                                             p_token2        =>  G_SQLERRM_TOKEN,
			                     p_token2_value  =>  sqlerrm);
End Check_Comp_Unique;

----------------------------------------------------------------------------
   --Check uniquness for COMPOSITE/Primary key  Columns in a table
----------------------------------------------------------------------------
Procedure  Check_Comp_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_tbl	                   IN unq_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    l_all_null  Boolean:=TRUE;
    l_query     VARCHAR2(3000);
    l_count Varchar2(1):='0';
    l_ind   Number:=0;
    l_index Number:=1;
    l_cols unq_tbl_type;
    TYPE UnqTyp  IS REF CURSOR;
    unq_csr  UnqTyp;
   --l_format varchar2(20):='YYYY';
   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;
        l_query:='select ''1'' from ' || p_view_name || ' where ';
        If p_col_tbl.Count>0 Then
            l_ind:=p_col_tbl.FIRST;

             Loop
                IF (p_col_tbl(l_ind).p_col_val is NULL) Then
                    l_query:=l_query||p_col_tbl(l_ind).p_col_name||' is null';
                else
                    l_query:=l_query||p_col_tbl(l_ind).p_col_name||'='''||replace(p_col_tbl(l_ind).p_col_val,'''','''''')||'''';
                    l_all_null := FALSE;
                End If;
                l_cols(l_index).p_col_name:=p_col_tbl(l_ind).p_col_name;
                Exit when l_ind=p_col_tbl.Last;
                l_query:=l_query||' and ' ;
                l_ind:=p_col_tbl.Next(l_ind);
                l_index:=l_index+1;
            End Loop;

/*
            For i in l_index+1 .. 10
            LOOP
		l_cols(i).p_col_name:='';
            end loop;
*/
            If l_all_null Then
                    RAISE l_Null_Val_Exception;
            End if;



	--Execute query
            OPEN  unq_csr FOR l_query;

            FETCH unq_csr into l_count;
            Close unq_csr;
            IF (l_COUNT='1') THEN
		          x_return_status:=OKC_API.G_RET_STS_ERROR;
                   OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			               p_msg_name      =>  G_UNQS,
                                       p_token1        =>  G_COL_NAME_TOKEN1,
			               p_token1_value  =>  l_cols(1).p_col_name,
				       p_token2        =>  G_COL_NAME_TOKEN2,
			               p_token2_value  =>  Value_Exists(l_cols,2),
				       p_token3        =>  G_COL_NAME_TOKEN3,
			               p_token3_value  =>  Value_Exists(l_cols,3),
				       p_token4        =>  G_COL_NAME_TOKEN4,
			               p_token4_value  =>  Value_Exists(l_cols,4),
				       p_token5        =>  G_COL_NAME_TOKEN5,
			               p_token5_value  =>  Value_Exists(l_cols,5),
				       p_token6        =>  G_COL_NAME_TOKEN6,
			               p_token6_value  =>  Value_Exists(l_cols,6),
				       p_token7        =>  G_COL_NAME_TOKEN7,
			               p_token7_value  =>  Value_Exists(l_cols,7),
				       p_token8        =>  G_COL_NAME_TOKEN8,
			               p_token8_value  =>  Value_Exists(l_cols,8),
				       p_token9        =>  G_COL_NAME_TOKEN9,
			               p_token9_value  =>  Value_Exists(l_cols,9),
				       p_token10        => G_COL_NAME_TOKEN0,
			               p_token10_value  =>  Value_Exists(l_cols,10));
					 /*
                          OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                      p_msg_name      =>  G_UNQS,
                                       p_token1        =>  G_COL_NAME_TOKEN,
			               p_token1_value  =>  l_cols(1).p_col_name,
				       p_token2        =>  Column_Exists(l_cols.count>=2,G_COL_NAME_TOKEN),
			               p_token2_value  =>  Value_Exists(l_cols,2),
				       p_token3        =>  Column_Exists(l_cols.count>=3,G_COL_NAME_TOKEN),
			               p_token3_value  =>  Value_Exists(l_cols,3),
				       p_token4        =>  Column_Exists(l_cols.count>=4,G_COL_NAME_TOKEN),
			               p_token4_value  =>  Value_Exists(l_cols,4),
				       p_token5        =>  Column_Exists(l_cols.count>=5,G_COL_NAME_TOKEN),
			               p_token5_value  =>  Value_Exists(l_cols,5),
				       p_token6        =>  Column_Exists(l_cols.count>=6,G_COL_NAME_TOKEN),
			               p_token6_value  =>  Value_Exists(l_cols,6),
				       p_token7        =>  Column_Exists(l_cols.count>=7,G_COL_NAME_TOKEN),
			               p_token7_value  =>  Value_Exists(l_cols,7),
				       p_token8        =>  Column_Exists(l_cols.count>=8,G_COL_NAME_TOKEN),
			               p_token8_value  =>  Value_Exists(l_cols,8),
				       p_token9        =>  Column_Exists(l_cols.count>=9,G_COL_NAME_TOKEN),
			               p_token9_value  =>  Value_Exists(l_cols,9),
				       p_token10        =>  Column_Exists(l_cols.count>=10,G_COL_NAME_TOKEN),
			               p_token10_value  =>  Value_Exists(l_cols,10));
						*/
           END IF;
        End If;
         exception
            WHEN l_Null_Val_Exception then
                       x_return_status:=OKC_API.G_RET_STS_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_ALL_NVL);

       	    WHEN others then
         		 x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
			     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                         p_msg_name      =>  G_UNEXPECTED_ERROR,
                                                 p_token1        =>  G_SQLCODE_TOKEN,
			                         p_token1_value  =>  sqlcode,
                                                 p_token2        =>  G_SQLERRM_TOKEN,
			                         p_token2_value  =>  sqlerrm);
End Check_Comp_Unique;


procedure call_user_hook(x_return_status OUT NOCOPY VARCHAR2,
			 		   p_package_name IN VARCHAR2,
			 		   p_procedure_name IN VARCHAR2,
			 		   p_before_after IN VARCHAR2) IS
 begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
 end;

/*procedure call_user_hook(x_return_status OUT NOCOPY VARCHAR2,
			 		   p_package_name IN VARCHAR2,
			 		   p_procedure_name IN VARCHAR2,
			 		   p_before_after IN VARCHAR2) IS

  l_statement	     VARCHAR2(200);

  cursor c_pdf_using is
  SELECT uhcv.pdf_using_id
  FROM   okc_process_defs_b pdfv,
  	 okc_user_hook_calls_b uhcv
  WHERE  pdfv.id = uhcv.pdf_id
  AND    pdfv.package_name = upper(p_package_name)
  AND    pdfv.procedure_name = upper(p_procedure_name)
  ORDER BY uhcv.run_sequence;

  cursor c_user_hook(p_pdf_using IN NUMBER) is
  SELECT decode(pdf.package_name, null, rtrim(pdf.procedure_name),
         rtrim(pdf.package_name) || '.' || rtrim(pdf.procedure_name)) proc_name
  FROM   okc_process_defs_b pdf;
  WHERE  pdf.before_after = p_before_after
  AND    pdf.user_defined_yn = 'Y'
  AND    pdf.id = p_pdf_using;

BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    FOR l_c_pdf_using IN c_pdf_using LOOP
      FOR l_c_user_hook IN c_user_hook(l_c_pdf_using.pdf_using_id) LOOP
         l_statement := 'BEGIN ' || l_c_user_hook.proc_name ||
		  	 '(:return_status); END;';
         EXECUTE IMMEDIATE l_statement USING OUT x_return_status;
      IF ((x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
      OR (x_return_status = OKC_API.G_RET_STS_ERROR)) THEN
        return;
      END IF;
      END LOOP;
    END LOOP;
END call_user_hook;
*/

----------------------------------------------------------------------------
 -- Count number of business days between two dates
----------------------------------------------------------------------------
FUNCTION count_business_days(start_date IN DATE, end_date IN DATE)
return NUMBER is
  v_current_date Date := start_date;
  v_day_of_week Varchar2(10);  /* day of the week for v_current_date */
  v_counter     Number := 0; /* Counter for business days */
begin
  if end_date - start_date <= 0 then
     return(0);
  end if;
  loop
    v_current_date := v_current_date + 1;
    exit when v_current_date > end_date;
    v_day_of_week := to_char(v_current_date, 'fmDay');
    if v_day_of_week <> 'Saturday' and v_day_of_week <> 'Sunday' then
       v_counter := v_counter + 1;
    end if;
  end loop;
return(v_counter);
end count_business_days;

----------------------------------------------------------------------------
   --Check if valid code for a type in fnd lookup
----------------------------------------------------------------------------
FUNCTION Check_Lookup_Code (p_type in VARCHAR2,
                            p_code IN VARCHAR2) return VARCHAR2 is

  result Varchar2(1):= OKC_API.G_RET_STS_ERROR;

  -- Bug 3674499 Need to truncate for dates
  cursor C1 is    -- /striping/ only for p_type <> 'OKC_RULE_DEF'
          SELECT 'S'
          FROM   fnd_lookups fndlup
          where  fndlup.lookup_type = p_type
          and    fndlup.lookup_code = p_code
          and    trunc(sysdate) between
                         trunc(nvl(fndlup.start_date_active,sysdate))
                         and
                         nvl(fndlup.end_date_active,sysdate);

-- /striping/   only for p_type = 'OKC_RULE_DEF'
  cursor C2 is
          SELECT 'S'
          FROM   okc_rule_defs_v fndlup
          where  fndlup.rule_code = p_code;

 Begin
   IF (p_type  is NULL) OR (p_code  is NULL) Then
                    RAISE l_Null_Val_Exception;
   End If;
-- /striping/
   if p_type = 'OKC_RULE_DEF' then
      open C2;
      fetch C2 into result;
      if C2%NOTFOUND then  result := OKC_API.G_RET_STS_ERROR;  end if;
      close C2;
   else
      open C1;
      fetch C1 into result;
      if C1%NOTFOUND then  result := OKC_API.G_RET_STS_ERROR;  end if;
      close C1;
   end if;

   If result='S' then
     result:=OKC_API.G_RET_STS_SUCCESS;
   end if;
   return result;
 EXCEPTION
    WHEN l_Null_Val_Exception then
                       result := OKC_API.G_RET_STS_UNEXP_ERROR;
                       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_NVL_CODE);
                       return result;

    WHEN OTHERS THEN
                       result:=OKC_API.G_RET_STS_UNEXP_ERROR;
		       OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			                   p_msg_name      =>  G_UNEXPECTED_ERROR,
                                           p_token1        =>  G_SQLCODE_TOKEN,
			                   p_token1_value  =>  sqlcode,
                                           p_token2        =>  G_SQLERRM_TOKEN,
			                   p_token2_value  =>  sqlerrm);
                       If C1%ISOPEN Then  close C1;   End If;
                       If C2%ISOPEN Then  close C2;   End If;
                       return result;
END check_lookup_code;

-- functions from JOHN for JTF objects

FUNCTION GET_NAME_FROM_JTFV(
		p_object_code IN VARCHAR2,
		p_id1 IN VARCHAR2,
		p_id2 IN VARCHAR2)
RETURN VARCHAR2 IS
	l_name	VARCHAR2(255);
	l_from_table VARCHAR2(200);
	l_where_clause VARCHAR2(2000);
	l_sql_stmt VARCHAR2(500);
	l_not_found BOOLEAN;

	Cursor jtfv_csr IS
		SELECT FROM_TABLE, WHERE_CLAUSE
		FROM JTF_OBJECTS_B
		WHERE OBJECT_CODE = p_object_code;
	Type SOURCE_CSR IS REF CURSOR;
	c SOURCE_CSR;

BEGIN
	open jtfv_csr;
	fetch jtfv_csr into l_from_table, l_where_clause;
	l_not_found := jtfv_csr%NOTFOUND;
	close jtfv_csr;

	If (l_not_found) Then
	   --my_message('Cannot find OBJECT in JTF_OBJECTS_B table');
		return NULL;
	End if;

       	      l_sql_stmt := 'SELECT name FROM ' || l_from_table ||
			    ' WHERE ID1 = :id_1 AND ID2 = :id2';
	      If (l_where_clause is not null) Then
	          l_sql_stmt := l_sql_stmt || ' AND ' || l_where_clause;
	    End If;
           open c for l_sql_stmt using p_id1, p_id2;
        fetch c into l_name;
        l_not_found := c%NOTFOUND;
        close c;



	If (l_not_found) Then
	--my_message('Cannot find NAME in ' || l_from_table || ' table');
	   return NULL;
	End if;
	return l_name;
EXCEPTION
  when NO_DATA_FOUND then
	  If (jtfv_csr%ISOPEN) Then
		Close jtfv_csr;
	  End If;
	  If (c%ISOPEN) Then
		Close c;
	  End If;
	  return NULL;
END;

FUNCTION GET_DESC_FROM_JTFV(
		p_object_code IN VARCHAR2,
		p_id1 IN VARCHAR2,
		p_id2 IN VARCHAR2)
RETURN VARCHAR2 IS
	l_description	VARCHAR2(255);
	l_from_table VARCHAR2(200);
	l_where_clause VARCHAR2(2000);
	l_sql_stmt VARCHAR2(500);
	l_not_found BOOLEAN;

	Cursor jtfv_csr IS
		SELECT FROM_TABLE, WHERE_CLAUSE
		FROM JTF_OBJECTS_B
		WHERE OBJECT_CODE = p_object_code;
	Type SOURCE_CSR IS REF CURSOR;
	c SOURCE_CSR;

BEGIN
	open jtfv_csr;
	fetch jtfv_csr into l_from_table, l_where_clause;
	l_not_found := jtfv_csr%NOTFOUND;
	close jtfv_csr;

	If (l_not_found) Then
	   --my_message('Cannot find OBJECT in JTF_OBJECTS_B table');
		return NULL;
	End if;


        	l_sql_stmt := 'SELECT description FROM ' || l_from_table ||
 				    ' WHERE ID1 = :id_1 AND ID2 = :id2';
		If (l_where_clause is not null) Then
		   l_sql_stmt := l_sql_stmt || ' AND ' || l_where_clause;
		End If;
 		open c for l_sql_stmt using p_id1, p_id2;
		fetch c into l_description;
		l_not_found := c%NOTFOUND;
		close c;
	If (l_not_found) Then
	--my_message('Cannot find NAME in ' || l_from_table || ' table');
	   return NULL;
	End if;
	return l_description;
EXCEPTION
  when NO_DATA_FOUND then
	  If (jtfv_csr%ISOPEN) Then
		Close jtfv_csr;
	  End If;
	  If (c%ISOPEN) Then
		Close c;
	  End If;
	  return NULL;
END;

PROCEDURE GET_NAME_DESC_FROM_JTFV(
		p_object_code IN VARCHAR2,
		p_id1 IN VARCHAR2,
		p_id2 IN VARCHAR2,
		x_name OUT NOCOPY VARCHAR2,
		x_description OUT NOCOPY VARCHAR2)
IS
	l_name	VARCHAR2(255);
	l_description	VARCHAR2(255);
	l_from_table VARCHAR2(200);
	l_where_clause VARCHAR2(2000);
	l_sql_stmt VARCHAR2(500);
	l_not_found BOOLEAN;

	Cursor jtfv_csr IS
		SELECT FROM_TABLE, WHERE_CLAUSE
		FROM JTF_OBJECTS_B
		WHERE OBJECT_CODE = p_object_code;
	Type SOURCE_CSR IS REF CURSOR;
	c SOURCE_CSR;

BEGIN
	open jtfv_csr;
	fetch jtfv_csr into l_from_table, l_where_clause;
	l_not_found := jtfv_csr%NOTFOUND;
	close jtfv_csr;

	If (l_not_found) Then
	   --my_message('Cannot find OBJECT in JTF_OBJECTS_B table');
		return;
	End if;
	l_sql_stmt := 'SELECT name,description FROM ' || l_from_table ||
			    ' WHERE ID1 = :id_1 AND ID2 = :id2';
	If (l_where_clause is not null) Then
	   l_sql_stmt := l_sql_stmt || ' AND ' || l_where_clause;
	End If;
	open c for l_sql_stmt using p_id1, p_id2;
	fetch c into l_name,l_description;
	l_not_found := c%NOTFOUND;
	close c;
	If (l_not_found) Then
	  x_name := '';
	  x_description := '';
	--my_message('Cannot find NAME and DESCRIPTION in ' || l_from_table || ' table');
	Else
	  x_name := l_name;
	  x_description := l_description;
	End if;
EXCEPTION
  when NO_DATA_FOUND then
	  If (jtfv_csr%ISOPEN) Then
		Close jtfv_csr;
	  End If;
	  If (c%ISOPEN) Then
		Close c;
	  End If;
	  x_name := NULL;
	  x_description := NULL;
END;

FUNCTION  GET_SQL_FROM_JTFV(p_object_code IN VARCHAR2)
RETURN VARCHAR2 IS
     l_from_table VARCHAR2(200);
     l_where_clause VARCHAR2(2000);
     l_order_by_clause VARCHAR2(200);
     l_return_str VARCHAR(2500);
     l_not_found BOOLEAN;
     Cursor jtfv_csr(p_object_code IN VARCHAR2) Is
		  SELECT from_table, where_clause, order_by_clause
		  FROM jtf_objects_b
		  WHERE object_code = p_object_code;
BEGIN
    open jtfv_csr(p_object_code);
    fetch jtfv_csr into l_from_table, l_where_clause, l_order_by_clause;
    l_not_found := jtfv_csr%NOTFOUND;
    close jtfv_csr;
    If (l_not_found) Then
	  return NULL;
    Else
	  l_return_str := l_from_table;
	  If (l_where_clause is not null) Then
	     l_return_str := l_return_str || ' WHERE ' || l_where_clause;
	  End If;
	  If (l_order_by_clause is not null) Then
	      If (upper(substr(l_order_by_clause,1,8)) = 'ORDER BY') Then
		    l_return_str := l_return_str || ' ' || l_order_by_clause;
		 Else
		    l_return_str := l_return_str || ' ORDER BY ' || l_order_by_clause;
		 End If;
	  End If;
       return l_return_str;
    End If;
EXCEPTION
  when NO_DATA_FOUND then
	  If (jtfv_csr%ISOPEN) Then
		Close jtfv_csr;
	  End If;
	  return NULL;
END;

FUNCTION GET_SELECTNAME_FROM_JTFV(
              p_object_code IN VARCHAR2,
              p_id          IN NUMBER)
RETURN VARCHAR2 IS
      l_selname         VARCHAR2(2000);
      l_select_id       VARCHAR2(2000);
      l_select_name     VARCHAR2(2500);
      l_from_table      VARCHAR2(200);
      l_where_clause    VARCHAR2(2000);
      l_sql_stmt        VARCHAR2(2000);
      l_not_found       BOOLEAN;

      CURSOR jtfv_csr IS
             SELECT SELECT_ID,SELECT_NAME,FROM_TABLE,WHERE_CLAUSE
             FROM   JTF_OBJECTS_B
             WHERE  OBJECT_CODE = p_object_code;
      Type SOURCE_CSR IS REF CURSOR ;
      c SOURCE_CSR;
BEGIN
      OPEN jtfv_csr;
      FETCH jtfv_csr INTO l_select_id,l_select_name,l_from_table,l_where_clause;
      l_not_found := jtfv_csr%NOTFOUND;
      CLOSE jtfv_csr;
      IF l_not_found THEN
         RETURN NULL;
      END IF;

      IF p_object_code = 'OKC_K_LINE' THEN
      l_sql_stmt := 'SELECT contract_number||'||''''||' '||''''||'||contract_number_modifier||'||''''||' '||''''||'||line_number'||' '||
      'FROM okc_k_headers_b khr,okc_k_lines_b khl,okc_condition_headers_b cnh WHERE khr.id = khl.dnz_chr_id and cnh.object_id = khl.id and khl.Id = :id';
      ELSE
      l_sql_stmt := 'SELECT ' || l_select_name || ' FROM ' || l_from_table || ' WHERE ' || l_select_id || ' = :id';
	 /*l_sql_stmt := 'SELECT ' || l_select_name || ' FROM ' || l_from_table;

       IF l_where_clause IS NOT NULL THEN
          l_sql_stmt := l_sql_stmt || ' WHERE ' || l_where_clause;
       END IF;*/
      END IF;
      OPEN c FOR l_sql_stmt USING p_id;

      FETCH c INTO l_selname;
      l_not_found := c%NOTFOUND;
      CLOSE c;
      IF l_not_found THEN
         RETURN NULL;
      END IF;

      RETURN l_selname;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
           IF (jtfv_csr%ISOPEN) THEN
           CLOSE jtfv_csr;
           END IF;
           IF (c%ISOPEN) THEN
           CLOSE c;
           END IF;
           RETURN NULL;
END;

----------------------------------------------------------------------
---               get_k_access_level
----------------------------------------------------------------------
-- Function Get_K_Access_Level
-- This function checks whether the current user has access to a given
-- contract. The contract id and the subclass (optionally) are passed
-- in. The called from parameter denotes whether the function was called
-- from forms or the Java(security) code in contracts online. An orig
-- source code of KSSA_HDR means that the contract was created in contracts
-- online. Currently to isolate the contracts from contracts online and
-- the contracts created in forms, a contracts created in forms will have
-- only a read access in online, except attachments. Any
-- attachment created in forms, can be updated in contracts online subject
-- to the modify access being available to the user. Any contract created
-- in contracts online can be modified in forms as per the rules pertaining
-- to forms contracts.
-- It returns the highest type of access that the user has based on the
-- setup and the source. The types are:
--     U - Update
--     R - Read only
--     N - No access
-- For contracts online, a null will be returned, if the contract was not found
----------------------------------------------------------------------

Function Get_K_Access_Level(p_chr_id IN NUMBER,
                            p_scs_code IN VARCHAR2 ,
                            p_called_from IN VARCHAR2 ,    -- F for forms, W for contracts online
                            p_update_attachment IN VARCHAR2 ,
			    p_orig_source_code IN VARCHAR2)
  RETURN Varchar2 IS

  l_scs_code okc_k_headers_b.scs_code%TYPE;

  l_partner_cat           CONSTANT Varchar2(7) := 'PARTNER';

  l_modify_access         CONSTANT Varchar2(1) := 'U';
  l_read_access           CONSTANT Varchar2(1) := 'R';
  l_no_access             CONSTANT Varchar2(1) := 'N';

  l_resp_access           okc_subclass_resps.access_level%TYPE;
  l_resource_access       okc_subclass_resps.access_level%TYPE;
  l_group_access          okc_k_accesses.access_level%TYPE;
  l_group_id              okc_k_accesses.group_id%TYPE;

  l_row_notfound          Boolean;
  l_group_has_read_access Boolean;

  l_date                  Date := Sysdate;
  l_orig_sys_source_code  okc_k_headers_v.orig_system_source_code%TYPE;
  l_ret_status            Varchar2(1) ;
  l_k_check               Varchar2(1);

  l_multiorg 		  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('OKC_VIEW_K_BY_ORG'),'N');
  l_authoring_org_id 	  number;
  l_org_id		  number := NVL(FND_PROFILE.VALUE('ORG_ID'), -99);

  exception_modify_access Exception;
  exception_read_access   Exception;
  exception_no_access     Exception;

  -- This cursor retrieves the sub class code for the contract. This is
  -- executed only if the subclass is not passed in

  CURSOR chr_csr IS
  SELECT scs_code,nvl(orig_system_source_code,'NOSOURCECODE')
    FROM okc_k_headers_b
   WHERE id = p_chr_id;

  -- This cursor checks to see the type of access granted to the current
  -- user's responsibility to the sub class

  CURSOR resp_csr IS
  SELECT ras.access_level
    FROM okc_subclass_resps ras
   WHERE ras.scs_code = l_scs_code
     AND ras.resp_id  = fnd_global.resp_id
     AND l_date BETWEEN ras.start_date AND nvl(ras.end_date, l_date);

  -- This cursor retrieves the resource id corresponding to the logged
  -- in user. The resource has to have a role of CONTRACT for this to be
  -- considered

  CURSOR res_csr IS
  SELECT res.resource_id
    FROM jtf_rs_resource_extns res,
         jtf_rs_role_relations rrr,
         jtf_rs_roles_b        rr
   WHERE res.user_id              = fnd_global.user_id
     AND l_date between res.start_date_active
                    and nvl(res.end_date_active, l_date)
     AND res.resource_id          = rrr.role_resource_id
     AND rrr.role_resource_type   = 'RS_INDIVIDUAL'
     AND nvl(rrr.delete_flag,'N') = 'N'
     AND l_date between rrr.start_date_active
                     and nvl(rrr.end_date_active, l_date)
     AND rrr.role_id              = rr.role_id
     AND rr.role_type_code        = 'CONTRACTS';

  -- This checks the access level for the resource and the contract

  CURSOR res_acc_csr is
  SELECT cas.access_level
    FROM okc_k_accesses cas
   WHERE cas.chr_id = p_chr_id
     AND cas.resource_id = g_user_resource_id;

  -- This cursor selects all the resource groups and the access level
  -- for the contract.

  CURSOR grp_acc_csr is
  SELECT cas.group_id,
         cas.access_level
    FROM okc_k_accesses cas
   WHERE cas.chr_id = p_chr_id
     AND cas.group_id is not null
   ORDER BY 2 DESC;

  -- This cursor selects all the resource groups that the resource
  -- belongs to. Fetched only once per session. The retrieved rows are
  -- stored in pl/sql global table and this table is used for
  -- subsequent contracts in the same session.

  CURSOR res_grp_csr is
  SELECT rgm.group_id
    FROM jtf_rs_group_members  rgm,
         jtf_rs_role_relations rrr,
         jtf_rs_roles_b        rr,
         jtf_rs_groups_b       rgb
   WHERE rgm.resource_id          = g_user_resource_id
     AND rgm.group_id             = rgb.group_id
     AND l_date between nvl(rgb.start_date_active, l_date)
                    and nvl(rgb.end_date_active, l_date)
     AND rgm.group_id             = rrr.role_resource_id
     AND nvl(rgm.delete_flag,'N') = 'N'
     AND rrr.role_resource_type   = 'RS_GROUP'
     AND nvl(rrr.delete_flag,'N') = 'N'
     AND l_date between rrr.start_date_active
                    and nvl(rrr.end_date_active, l_date)
     AND rrr.role_id              = rr.role_id
     AND rr.role_type_code        = 'CONTRACTS'
   UNION
  SELECT rgd.parent_group_id
    FROM jtf_rs_group_members  rgm,
         jtf_rs_groups_denorm  rgd,
         jtf_rs_role_relations rrr,
         jtf_rs_roles_b        rr,
         jtf_rs_groups_b       rgb
   WHERE rgm.resource_id          = g_user_resource_id
     AND nvl(rgm.delete_flag,'N') = 'N'
     AND rgd.group_id             = rgm.group_id
     AND rgd.parent_group_id      = rgb.group_id
     AND l_date between nvl(rgb.start_date_active, l_date)
                    and nvl(rgb.end_date_active, l_date)
     AND rgd.parent_group_id      = rrr.role_resource_id
     AND rrr.role_resource_type   = 'RS_GROUP'
     AND nvl(rrr.delete_flag,'N') = 'N'
     AND l_date between rrr.start_date_active
                     and nvl(rrr.end_date_active, l_date)
     AND rrr.role_id              = rr.role_id
     AND rr.role_type_code        = 'CONTRACTS';

-- Cursor to check for the existance of a contract (it could heve been deleted)
-- used only for contracts online.

 CURSOR c_check_contract(p_contract_id IN NUMBER) IS
  SELECT 'X'
  FROM okc_k_headers_b
  WHERE ID = p_contract_id;

--MMadhavi commenting for MOAC
/*
-- This cursor retrieves the authoring org id for that particular contract.
  CURSOR auth_org_csr IS
  SELECT authoring_org_id
  FROM   okc_k_headers_b
  WHERE  id = p_chr_id;
*/

BEGIN

  -- Global variable g_user_id introduced to resolve the problem of connection pooling.
  -- This variable is not guaranteed to be same for the same user across multiple
  -- web requests. So everytime a global needs to be checked, make sure it was built
  -- by the same user.

  Set_Connection_Context;

  -- If no contract identifier is passed, then do not allow access

  If p_chr_id Is Null Then
    Raise Exception_No_Access;
  End If;


--MMadhavi commenting for MOAC
/*
  If l_multiorg = 'Y' Then
     Open auth_org_csr;
     Fetch auth_org_csr Into l_authoring_org_id;
     Close auth_org_csr;

     If l_org_id <> l_authoring_org_id Then
        Raise Exception_No_Access;
     End If;
  End If;
 */
  -- If the sub class is not passed in, then derive it using the
  -- contract identifier

  l_scs_code := p_scs_code;
  l_orig_sys_source_code := p_orig_source_code;

    If l_scs_code Is Null Then

    -- Get the subclass/category from the contracts table
    Open chr_csr;

    Fetch chr_csr Into l_scs_code,l_orig_sys_source_code;

    l_row_notfound := chr_csr%NotFound;

    Close chr_csr;

    If l_row_notfound Then
      Raise Exception_No_Access;
    End If;
    End If;
  -- fnd_log.string(1, 'okc', 'l_scs_code : ' || l_scs_code);

  -- Determine if the access for the category and responsibility has
  -- been determined earlier and cached in the global variables. If not,
  -- then determine it using the resp_csr g_resp_access is initialized
  -- to g_miss_char. If this could not be determined the first time
  -- around, the variables are set to null and not examined during the
  -- next round

  /* If (l_scs_code <> g_scs_code) OR
     (g_resp_access = OKC_API.G_MISS_CHAR) Then */

  If (l_scs_code <> g_scs_code) OR (g_reset_resp_flag) Then

    Open resp_csr;

    Fetch resp_csr Into l_resp_access;

    l_row_notfound := resp_csr%NotFound;

    Close resp_csr;

    If l_row_notfound Then
      l_resp_access := Null;
    End If;

    -- fnd_log.string(1, 'okc', 'l_resp_access : ' || l_resp_access);
    -- Save the current access level into global variables. If no access
    -- was determined, the local variables hold null and so do the global
    -- variables

    g_scs_code    := l_scs_code;
    g_resp_access := l_resp_access;

    If g_reset_resp_flag Then
      g_reset_resp_flag := False;
    End If;

  End If;

  -- Check the access level at the category and responsibility level first

  If g_resp_access = l_modify_access Then
    Raise Exception_Modify_Access;
  End If;

  -- If could not find 'Update' access from the user's responsibility,
  -- continue to check if granted any access at the user resource level.
  -- If the user resource id is not determined earlier, then retrieve it
  -- and cache it as it will not change during the current session

  If (g_user_resource_id = OKC_API.G_MISS_NUM) Or
	(g_reset_access_flag) Then

    Open res_csr;

    Fetch res_csr Into g_user_resource_id;

    l_row_notfound := res_csr%NotFound;

    Close res_csr;

    g_groups_processed := False;

    If l_row_notfound Then
      g_user_resource_id := Null;
    End If;
    -- fnd_log.string(1, 'okc', 'g_user_resource_id : ' || g_user_resource_id);
  End If;

  -- Determine the access level for the resource id on the contract

  If g_user_resource_id Is Not Null Then

    Open res_acc_csr;

    Fetch res_acc_csr Into l_resource_access;

    Close res_acc_csr;

    If l_resource_access = l_modify_access Then
      Raise Exception_Modify_Access;
    End If;

    -- fnd_log.string(1, 'okc', 'l_resource_access : ' || l_resource_access);
    -- Since the resource does not have Update access, we need to get its
    -- parent group and its grand parent groups (recursively). Cache it in
    -- the global pl/sql table since this hierarchy is not going to change
    -- for a resource. So do it only for the first time. Do this by
    -- examining the global variable g_groups_processed. This indicates
    -- that the array of groups has been retrieved for the session

    If g_groups_processed Then
	 null;
    Else
      Open res_grp_csr;
      Fetch res_grp_csr BULK COLLECT INTO g_sec_groups;
      Close res_grp_csr;
      g_groups_processed := True;
    End If;

    -- Finally check for any access granted at the group level.
    -- Do it only if the resource belongs to at least one group
    -- fnd_log.string(1, 'okc', 'g_sec_groups.count : ' || to_char(g_sec_groups.count));

    l_group_has_read_access := False;
    If g_sec_groups.COUNT > 0 Then
      Open grp_acc_csr;
      Loop
        -- Get all the groups assigned to the contract
        Fetch grp_acc_csr Into l_group_id, l_group_access;
	   Exit When grp_acc_csr%NOTFOUND;
        For i in 1 .. g_sec_groups.LAST
        Loop
	     If g_sec_groups(i) = l_group_id Then
            -- If the groups match and access level is 'U', exit immediately
		  If l_group_access = l_modify_access Then
              Raise Exception_Modify_Access;
            End If;
		  If l_group_access = l_read_access Then
		    l_group_has_read_access := True;
            End If;
          End If;
        End Loop;
      End Loop;
      Close grp_acc_csr;
    End If;

  End If;

  -- fnd_log.string(1, 'okc', 'l_resource_access : ' || l_resource_access);
  -- fnd_log.string(1, 'okc', 'l_group_access : ' || l_group_Access);
  -- fnd_log.string(1, 'okc', 'g_resp_access : ' || g_resp_access);
  If (l_read_access in (g_resp_access, l_resource_access)) Or
     l_group_has_read_access Then
    Raise Exception_Read_Access;
  End If;

  Raise Exception_No_Access;

EXCEPTION

  When Exception_Modify_Access Then
    -- fnd_log.string(1, 'okc', 'Modify Access Allowed');
    If grp_acc_csr%ISOPEN Then
      Close grp_acc_csr;
    End If;
    If g_reset_access_flag Then
      g_reset_access_flag := False;
    End If;

    l_ret_status := l_modify_access;

  --  IF p_called_from = 'F' and l_orig_sys_source_code = 'KSSA_HDR' THEN -- KOL contract called in Forms
  --     l_ret_status := l_read_access;
  --  ELSE
    /*  Check for the contract created from forms */
       IF p_called_from = 'W' and l_orig_sys_source_code <> 'KSSA_HDR' THEN  -- Forms contract called in KOL
            l_ret_status := l_read_access;
          IF p_update_attachment = 'true' THEN
    /*  The contract created from forms,but can the attachment be updated in contracts online */
  --         IF OKC_ASSENT_PUB.header_operation_allowed(p_chr_id,'UPDATE') = OKC_API.G_TRUE THEN
               l_ret_status := l_modify_access;
  --         END IF;  -- if update allowed in okc_assent_pub
          END IF;  -- if update attachment = true

       ELSIF p_called_from = 'W' and l_orig_sys_source_code = 'KSSA_HDR' THEN  -- Created in KOL and accessed in KOL
  --      IF OKC_ASSENT_PUB.header_operation_allowed(p_chr_id,p_operation_allowed) <> OKC_API.G_TRUE THEN
  --         l_ret_status := l_read_access;
  --      END IF;  -- if update/delete allowed in okc_assent_pub
       NULL;

       END IF; -- if the p_mode = 'W' and the source code <> 'KSSA_HDR'

       --If called from KOL and the contract category is Partner
       --Give readonly access
       IF p_called_from = 'W' AND l_scs_code = l_partner_cat THEN
            l_ret_status := l_read_access;
       END IF;

  --  END IF;

    Return(l_ret_status);

  When Exception_Read_Access Then
    -- fnd_log.string(1, 'okc', 'Read Access Allowed');
    If g_reset_access_flag Then
      g_reset_access_flag := False;
    End If;
    Return(l_read_access);

  When Exception_No_Access Then
    -- fnd_log.string(1, 'okc', 'No Access Allowed');
    l_ret_status := l_no_access;

    If g_reset_access_flag Then
      g_reset_access_flag := False;
    End If;

    -- The No Access could be because of the actual access itself
    -- or in the case where a contract could not be found. If the access
    -- level for a contract is checked from the web, then the return result
    -- should be more accurate. Hence 'N' will be returned for a no access
    -- and a NULL will be returned, if the contract itself was not found.
    -- This is applicable only for contracts online.

   IF p_called_from = 'W' THEN
       OPEN c_check_contract(p_chr_id);
       FETCH c_check_contract INTO l_k_check;
       IF c_check_contract%NOTFOUND THEN
          l_ret_status := NULL;
       END IF;
       CLOSE c_check_contract;
   END IF;

    Return(l_ret_status);
End get_k_access_level;

-----------------------------------------------------------------------------
-- Get_All_K_Access_Level - Function to call different security
--                          function depending on the application ID
-----------------------------------------------------------------------------
Function Get_All_K_Access_Level(p_chr_id IN NUMBER,
                                p_application_id IN NUMBER ,
                                p_scs_code IN VARCHAR2 )
  Return Varchar2 IS
  l_access_level Varchar2(30);
  l_application_id okc_k_headers_b.application_id%TYPE := p_application_id;
  cursor c1 is
  select application_id
    from okc_k_headers_b
   where id = p_chr_id;
BEGIN
  -- For OKE Contracts (Application ID = 777), use OKE's security function
  If p_application_id Is Null Then
    Open c1;
    Fetch c1 Into l_application_id;
    Close c1;
    -- If c1%NotFound we can assume, it is non-OKE Contract
  End If;
  If l_application_id = 777 Then
    l_access_level := Oke_K_Security_Pkg.Get_K_Access(p_chr_id);
    -- Transform OKE's return value to OKC's return value
    If l_access_level = 'EDIT' Then
      l_access_level := 'U';
    Elsif l_access_level = 'VIEW' Then
      l_access_level := 'R';
    Else
      l_access_level := 'N';
    End If;
  Else
    l_access_level := Get_K_Access_Level(p_chr_id, p_scs_code);
  End If;
  Return(l_access_level);
END Get_All_K_Access_Level;

--------------------------------------------------------------------------
-- Function returns TRUE if user has modify access on a contract category
--------------------------------------------------------------------------
FUNCTION Create_K_Access(p_scs_code varchar2) RETURN BOOLEAN IS

  Cursor access_level_csr is
    Select access_level
    from okc_subclass_resps_v
    where scs_code=p_scs_code
    and resp_id=fnd_global.resp_id
    and sysdate between start_date and nvl(end_date,sysdate);

 Cursor subclass_csr is
   Select meaning
   from okc_subclasses_v
   where code=p_scs_code;

  l_scs_meaning        VARCHAR2(30);
  l_create_access_level VARCHAR2(1);

BEGIN
     Open access_level_csr;
     Fetch access_level_csr into l_create_access_level;
     Close access_level_csr;

     If l_create_access_level = 'U' then
        Return(TRUE);
     Else
	Open subclass_csr;
	Fetch subclass_csr into l_scs_meaning;
	Close subclass_csr;
     OKC_API.SET_MESSAGE(p_app_name     =>'OKC',
    				     p_msg_name     =>'OKC_CREATE_NA',
			          p_token1       =>'CATEGORY',
				     p_token1_value =>l_scs_meaning);
     Return(FALSE);
     End If;
END Create_K_Access;

-----------------------------------------------------------------------------
--copies clob text to other recs with same source_lang as lang
------------------------------------------------------------------------------
FUNCTION Copy_CLOB(id number,release varchar2,lang varchar2)
 RETURN VARCHAR2 IS
  l_stat      VARCHAR2(1):='S';
  begin
    update okc_std_art_versions_tl set text=(select text from okc_std_art_versions_tl
	                               where sae_id=id and sav_release=release and language=lang)
	 where sae_id=id and sav_release=release and source_lang=lang and language<>lang;
    return l_stat;
 EXCEPTION
	    WHEN OTHERS THEN
		  l_stat:='E';
		  return l_stat;
END Copy_CLOB;


-----------------------------------------------------------------------------
-- If p_text passed, updates the text with p_text.
-- Otherwise copies clob text to other recs with same source_lang as lang
-- in OKC_K_ARTICLES_TL table
------------------------------------------------------------------------------
-- new 11510 version of FUNCTION Copy_Articles_Text
  FUNCTION Copy_Articles_Text(p_id NUMBER,lang VARCHAR2,p_text VARCHAR2 ) RETURN VARCHAR2
   IS
    l_return_status	VARCHAR2(1) := 'S';
    length            NUMBER;
   BEGIN
    IF (p_text IS NOT NULL) THEN
      UPDATE okc_article_versions
       SET article_text             = p_text,
         object_version_number      = object_version_number+1,
         last_updated_by            = FND_GLOBAL.USER_ID,
         last_update_login          = FND_GLOBAL.LOGIN_ID,
         last_update_date           = Sysdate
       WHERE article_version_id=(SELECT article_version_id
                                   FROM okc_k_articles_b WHERE id = p_id);
    END IF;
    RETURN l_return_status;
   EXCEPTION
    WHEN OTHERS THEN
	  l_return_status := 'E';
	  RETURN l_return_status;
  END Copy_Articles_Text;
/* 11510
FUNCTION Copy_Articles_Text(p_id NUMBER,lang varchar2,p_text VARCHAR2 ) RETURN VARCHAR2 Is
  l_return_status	VARCHAR2(1) := 'S';
  length            NUMBER;
Begin
    If (p_text is null) Then
         select dbms_lob.getlength(text) into length from okc_k_articles_tl
         where id = p_id and language = lang;
         If length > 0 Then
            update okc_k_articles_tl
            set text=(select text from okc_k_articles_tl
                      where id=p_id and language=lang)
                where id = p_id and source_lang = lang and language <> lang;
         Else
            update okc_k_articles_tl
            set text=NULL
                where id = p_id and language = lang;
         End If;
    Else
	  update okc_k_articles_tl
	  set text= p_text
	  where id = p_id and language = lang;
    End If;
    return l_return_status;
 EXCEPTION
    WHEN OTHERS THEN
	  l_return_status := 'E';
	  return l_return_status;
End Copy_Articles_Text;
*/

-- new 11510 version of FUNCTION Copy_Articles_Varied_Text
  FUNCTION Copy_Articles_Varied_Text(
              p_article_id NUMBER,
              p_sae_id NUMBER,
              lang VARCHAR2
   ) RETURN VARCHAR2 Is
    l_return_status	VARCHAR2(1) := 'S';
   BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_UTIL');
       okc_debug.log('1000: Entered Copy_Articles_Varied_Text', 2);
       okc_debug.log('1001: p_article_id: '||p_article_id, 2);
       okc_debug.log('1002: p_sae_id: '||p_sae_id, 2);
    END IF;
    UPDATE okc_article_versions
     SET article_text
         = (SELECT article_text FROM okc_article_versions
             WHERE article_id=p_sae_id
               AND sysdate BETWEEN start_date AND Nvl(end_date,Sysdate+1) ),
       object_version_number      = object_version_number+1,
       last_updated_by            = FND_GLOBAL.USER_ID,
       last_update_login          = FND_GLOBAL.LOGIN_ID,
       last_update_date           = Sysdate
     WHERE article_version_id
      =(SELECT article_version_id
          FROM okc_k_articles_b WHERE id = p_article_id);
    IF (l_debug = 'Y') THEN
      okc_debug.log('1010: Leaving  Copy_Articles_Varied_Text', 2);
      okc_debug.Reset_Indentation;
    END IF;
    return l_return_status;
  EXCEPTION
   When OTHERS Then
     IF (l_debug = 'Y') THEN
       okc_debug.log('1020: Leaving Copy_Articles_Varied_Text because of an exception: '||sqlerrm, 2);
       okc_debug.Reset_Indentation;
     END IF;
     OKC_API.SET_MESSAGE(
         p_app_name      =>  G_APP_NAME,
         p_msg_name      =>  G_UNEXPECTED_ERROR,
         p_token1        =>  G_SQLCODE_TOKEN,
         p_token1_value  =>  sqlcode,
         p_token2        =>  G_SQLERRM_TOKEN,
         p_token2_value  =>  sqlerrm);
     return 'E';
  END;

/* 11510
FUNCTION Copy_Articles_Varied_Text(p_article_id NUMBER,
							p_sae_id NUMBER,
							lang VARCHAR2)
RETURN VARCHAR2 Is

	l_release			VARCHAR2(50);
	l_return_status	VARCHAR2(1) := 'S';

	Cursor l_savv_scr Is
		SELECT sav_release
		FROM okc_std_art_versions_b
		WHERE sae_id = p_sae_id
		AND date_active = (SELECT max(date_active)
					    FROM okc_std_art_versions_b
					    WHERE sae_id = p_sae_id
                                            AND date_active <= sysdate);
BEGIN

	Open l_savv_scr;
	Fetch l_savv_scr Into l_release;
	Close l_savv_scr;

	update okc_k_articles_tl
	set text = (select text
			  from okc_std_art_versions_tl
			  where sae_id = p_sae_id
			  and sav_release = l_release
			  and language = lang)
	where id = p_article_id;

	return l_return_status;
EXCEPTION
	When NO_DATA_FOUND then
		If (l_savv_scr%ISOPEN) Then
		    close l_savv_scr;
		End If;
		OKC_API.SET_MESSAGE(
				p_app_name      =>  G_APP_NAME,
			     p_msg_name      =>  G_UNEXPECTED_ERROR,
                    p_token1        =>  G_SQLCODE_TOKEN,
			     p_token1_value  =>  sqlcode,
                    p_token2        =>  G_SQLERRM_TOKEN,
			     p_token2_value  =>  sqlerrm);
		return 'E';
	When OTHERS Then
		If (l_savv_scr%ISOPEN) Then
		    close l_savv_scr;
		End If;
		OKC_API.SET_MESSAGE(
				p_app_name      =>  G_APP_NAME,
			     p_msg_name      =>  G_UNEXPECTED_ERROR,
                    p_token1        =>  G_SQLCODE_TOKEN,
			     p_token1_value  =>  sqlcode,
                    p_token2        =>  G_SQLERRM_TOKEN,
			     p_token2_value  =>  sqlerrm);
		return 'E';
END;
*/
-----------------------------------------------------------------------------
--Function to retrieve the Organization Title for forms; called from OKCSTAND.pll
------------------------------------------------------------------------------
FUNCTION Get_Org_Window_Title RETURN VARCHAR2
  IS
  l_multi_org           VARCHAR2(1);
  l_multi_cur           VARCHAR2(1);
  l_wnd_context         VARCHAR2(80);
  l_id                  VARCHAR2(15);

  Cursor C1 IS
      select g.short_name||decode(g.mrc_sob_type_code, 'N', NULL,
                               decode(l_multi_cur, 'N', NULL,
                                      ': ' || g.currency_code))
      from okx_set_of_books_v g
      where g.set_of_books_id=NVL(fnd_profile.value('GL_SET_OF_BKS_ID'),0);
  Cursor C2  IS
      select g.short_name||decode(g.mrc_sob_type_code, 'N', NULL,
                               decode(l_multi_cur, 'N', NULL,
                                      ': ' || g.currency_code))
      from okx_set_of_books_v g, okx_organization_defs_v o
      where o.id1=NVL(fnd_profile.value('ORG_ID'),0)
            and g.set_of_books_id = to_number(o.set_of_books_id)
            and o.organization_type= 'OPERATING_UNIT'
            and o.information_type= 'Operating Unit Information' ;
BEGIN
  /*
  ***
  *** Get multi-org and MRC information on the current
  *** product installation.
  ***
   */
  SELECT        nvl(multi_org_flag, 'N')
  ,             nvl(multi_currency_flag, 'N')
  INTO          l_multi_org
  ,             l_multi_cur
  FROM          fnd_product_groups;
  /*
  ***
  *** Case #1 : Non-Multi-Org or Multi-SOB
  ***
  ***  A. MRC not installed, OR
  ***     MRC installed, Non-Primary/Reporting Books
  ***       Form Name (SOB Short Name) - Context Info
  ***       e.g. Maintain Forecast(US OPS) - Forecast Context Info
  ***
  ***  B. MRC installed, Primary Books
  ***       Form Name (SOB Short Name: Primary Currency) - Context Info
  ***       e.g. Maintain Forecast(US OPS: USD) - Forecast Context Info
  ***
  ***  C. MRC installed, Reporting Books
  ***       Form Name (SOB Short Name: Reporting Currency) - Context Info
  ***       e.g. Maintain Forecast(US OPS: EUR) - Forecast Context Info
  ***
   */
  IF (l_multi_org = 'N') THEN
              Open C1;
              Fetch C1 into l_wnd_context;
              Close C1;
  /*
  ***
  *** Case #2 : Multi-Org
  ***
  ***  A. MRC not installed, OR
  ***     MRC installed, Non-Primary/Reporting Books
  ***       Form Name (OU Name) - Context Info
  ***       e.g. Maintain Forecast(US West) - Forecast Context Info
  ***
  ***  B. MRC installed, Primary Books
  ***       Form Name (OU Name: Primary Currency) - Context Info
  ***       e.g. Maintain Forecast(US West: USD) - Forecast Context Info
  ***
  ***  C. MRC installed, Reporting Books
  ***       Form Name (OU Name: Reporting Currency) - Context Info
  ***       e.g. Maintain Forecast(US West: EUR) - Forecast Context Info
  ***
   */
  ELSE
              Open C2;
              Fetch C2 into l_wnd_context;
              Close C2;
  END IF;
  return l_wnd_context;
  exception
     when others then
          return l_wnd_context;
END Get_Org_Window_Title;


PROCEDURE forms_savepoint(p_savepoint IN VARCHAR2) IS
BEGIN
  dbms_transaction.savepoint(p_savepoint);
END;

PROCEDURE forms_rollback(p_savepoint IN VARCHAR2) IS
BEGIN
  dbms_transaction.rollback_savepoint(p_savepoint);
END;

--------------------------------------------------------------------------------
-- PROCEDURE init_msg_list
--------------------------------------------------------------------------------
PROCEDURE init_msg_list (
	p_init_msg_list	IN VARCHAR2
) IS
BEGIN
  OKC_API.init_msg_list(p_init_msg_list);
END init_msg_list;

--------------------------------------------------------------------------------
-- PROCEDURE set_message
--------------------------------------------------------------------------------
PROCEDURE set_message (
	p_app_name		IN VARCHAR2 ,
	p_msg_name		IN VARCHAR2,
	p_token1		IN VARCHAR2 ,
	p_token1_value		IN VARCHAR2 ,
	p_token2		IN VARCHAR2 ,
	p_token2_value		IN VARCHAR2 ,
	p_token3		IN VARCHAR2 ,
	p_token3_value		IN VARCHAR2 ,
	p_token4		IN VARCHAR2 ,
	p_token4_value		IN VARCHAR2 ,
	p_token5		IN VARCHAR2 ,
	p_token5_value		IN VARCHAR2 ,
	p_token6		IN VARCHAR2 ,
	p_token6_value		IN VARCHAR2 ,
	p_token7		IN VARCHAR2 ,
	p_token7_value		IN VARCHAR2 ,
	p_token8		IN VARCHAR2 ,
	p_token8_value		IN VARCHAR2 ,
	p_token9		IN VARCHAR2 ,
	p_token9_value		IN VARCHAR2 ,
	p_token10		IN VARCHAR2 ,
	p_token10_value		IN VARCHAR2
) IS
BEGIN
	FND_MESSAGE.SET_NAME( P_APP_NAME, P_MSG_NAME);
	IF (p_token1 IS NOT NULL) AND (p_token1_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token1,
					VALUE		=> p_token1_value);
	END IF;
	IF (p_token2 IS NOT NULL) AND (p_token2_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token2,
					VALUE		=> p_token2_value);
	END IF;
	IF (p_token3 IS NOT NULL) AND (p_token3_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token3,
					VALUE		=> p_token3_value);
	END IF;
	IF (p_token4 IS NOT NULL) AND (p_token4_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token4,
					VALUE		=> p_token4_value);
	END IF;
	IF (p_token5 IS NOT NULL) AND (p_token5_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token5,
					VALUE		=> p_token5_value);
	END IF;
	IF (p_token6 IS NOT NULL) AND (p_token6_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token6,
					VALUE		=> p_token6_value);
	END IF;
	IF (p_token7 IS NOT NULL) AND (p_token7_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token7,
					VALUE		=> p_token7_value);
	END IF;
	IF (p_token8 IS NOT NULL) AND (p_token8_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token8,
					VALUE		=> p_token8_value);
	END IF;
	IF (p_token9 IS NOT NULL) AND (p_token9_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token9,
					VALUE		=> p_token9_value);
	END IF;
	IF (p_token10 IS NOT NULL) AND (p_token10_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token10,
					VALUE		=> p_token10_value);
	END IF;
	FND_MSG_PUB.add;
END set_message;

/*
-------------------------------------------------------------------------------
-- Procedure:           get_trace_path
-- Purpose:             define the root directory for trace files
--
-- In Parameters:
-- Out Parameters:
--
FUNCTION get_trace_path (p_path IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
IF INSTR(p_path,',',1) = 0 THEN
   IF INSTR(p_path, ';', 1) = 0 THEN
      RETURN SUBSTR(p_path, 1, LENGTH(p_path));
   ELSE
      RETURN SUBSTR(p_path, 1, INSTR(p_path, ';', 1)-1);
   END IF;
ELSE
   RETURN SUBSTR(p_path, 1 , INSTR(p_path, ',', 1)-1);
END IF;

EXCEPTION
WHEN OTHERS  THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'GET_TRACE_PATH');
   RAISE;
END get_trace_path;

-------------------------------------------------------------------------------
-- Procedure:           close_trace_file
-- Purpose:             close the trace file for the current session
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE close_trace_file
IS
BEGIN
   UTL_FILE.FCLOSE(l_trace_file);

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'CLOSE_TRACE_FILE');
   RAISE;
END close_trace_file;

------------------------------------------------------------------------------
-- Procedure:           Reset_trace_context
-- Purpose:             close the trace file for the current session
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE Reset_trace_context
IS
BEGIN
   IF SUBSTR(LTRIM(RTRIM(FND_PROFILE.VALUE('AFLOG_ENABLED'))),1,1) = 'Y'
   THEN     -- Disable the log_enabled mode i.e. stop debugging mode
        FND_PROFILE.PUT('AFLOG_ENABLED','N');
   END IF;

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'RESET_TRACE_CONTEXT');
   RAISE;
END reset_trace_context;

-------------------------------------------------------------------------------
-- Procedure:           open_trace_file
-- Purpose:             open a trace file for the current session
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE open_trace_file(g_request_id    IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2)
IS
l_parameter_value    VARCHAR2(255);
l_process_id         NUMBER;
l_session_id         NUMBER;
BEGIN
   IF g_request_id IN (0, -1) THEN
	 --NO conc. prog. is running
      SELECT pr.spid
            ,se.sid
	    ,se.program
	    ,se.module
      INTO  l_process_id
           ,l_session_id
	   ,l_program
	   ,l_module
      FROM v$session         se
          ,v$process         pr
      WHERE se.audsid = USERENV('SESSIONID')
      AND  se.paddr  = pr.addr;

      SELECT pa.value
      INTO  l_parameter_value
      FROM v$parameter       pa
      WHERE  pa.name   = 'utl_file_dir';

      l_trace_path := get_trace_path (l_parameter_value);

      ---
      --- The file mode must be opened in w mode in 7.3, otherwise in a mode
      ---
      BEGIN
         l_trace_file := utl_file.fopen(l_trace_path, g_trc_trace_file_prefix
                                    ||  TO_CHAR(l_process_id)
                                    ||  '_'
                                    ||  TO_CHAR(l_session_id)
                                    ||  g_trc_trace_file_suffix, 'a');
      EXCEPTION
      WHEN utl_file.invalid_mode THEN
         l_trace_file := utl_file.fopen(l_trace_path, g_trc_trace_file_prefix
                                       ||  TO_CHAR(l_process_id)
                                       ||  '_'
                                       ||  TO_CHAR(l_session_id)
                                       ||  g_trc_trace_file_suffix, 'w');
      END;
      l_trace_file_name := g_trc_trace_file_prefix
                                       ||  TO_CHAR(l_process_id)
                                       ||  '_'
                                       ||  TO_CHAR(l_session_id)
                                       ||  g_trc_trace_file_suffix;
      l_complete_trace_file_name := l_trace_path||'/'||l_trace_file_name;
   ELSE
	 --Select and Open the log file
	 l_trace_file.id:=FND_FILE.log;
	 FND_FILE.put_line(l_trace_file.id, ' ');
	 --Select and Open the output file
	 l_output_file.id:=FND_FILE.output;
	 FND_FILE.put_line(l_output_file.id, ' ');
	 --Get log and output file names
	 FND_FILE.get_names(l_trace_file_name, l_output_file_name);
   END IF;
   x_return_status:=OKC_API.g_true;
EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'OPEN_TRACE_FILE');
   -- RAISE; --BUG# 1850274
   x_return_status:=OKC_API.g_false;
END open_trace_file;
*/

------------------------------------------------------------------------------
-- Procedure:           set_trace_context
-- Purpose:             Open the log and output files for the
--                      concurrent program else set up the context
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE set_trace_context(g_request_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
IS

BEGIN

   IF g_request_id NOT IN (0, -1) THEN   -- Conc. prog. is running
         --Select and Open the log file
                l_trace_file.id:=FND_FILE.log;
                FND_FILE.put_line(l_trace_file.id, ' ');
         --Select and Open the output file
                l_output_file.id:=FND_FILE.output;
                FND_FILE.put_line(l_output_file.id, ' ');
         --Get log and output file names
                FND_FILE.get_names(l_trace_file_name, l_output_file_name);
   END IF;
   x_return_status:=OKC_API.g_true;
EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'SET_TRACE_CONTEXT');
   --RAISE;
   x_return_status:=OKC_API.g_false; --Bug # 1850274
END set_trace_context;

-------------------------------------------------------------------------------
-- Procedure:           print_trace
-- Purpose:             write a trace line in the trace file
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_trace (p_indent     IN NUMBER,
                       p_trace_line IN VARCHAR2,
                       p_level      IN NUMBER ,
                       p_module     IN VARCHAR2 )
IS
l_indent NUMBER;
l_mesg   VARCHAR2(1900);
l_level  NUMBER;
l_db_module VARCHAR2(200);

--	The print trace procedure serves as a wrapper to the OKC_DEBUG API.

BEGIN

l_indent :=p_indent;
l_level  := p_level;
l_db_module := p_module;

l_mesg:=LPAD(p_trace_line, LENGTH(p_trace_line)+(4*p_indent), ' ');

   IF l_trace_flag THEN     -- If true, write into fnd_log_messages
           IF (l_debug = 'Y') THEN
              OKC_DEBUG.log(l_mesg,l_level,l_db_module);
           END IF;
   ELSE     --  write into log file for the conc.program

        IF l_log_flag AND l_trace_file.id IS NOT NULL THEN
--            FND_FILE.PUT_LINE(l_trace_file.id, l_mesg);
-- Bug 1993476
            FND_FILE.PUT_LINE(l_trace_file.id, replace(l_mesg,OKC_API.G_MISS_CHAR));
        END IF;

   END IF;
EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'PRINT_TRACE');
   RAISE;
END print_trace;

-------------------------------------------------------------------------------
-- Procedure:           init_trace
-- Purpose:             setup the trace mode
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE init_trace
IS
g_request_id    NUMBER;
l_user_id       NUMBER;
l_log_enable    VARCHAR2(20);
l_session_id    NUMBER;
l_init_profile_log_enabled      varchar2(20);
l_init_profile_module_level     varchar2(20);
l_init_profile_module_name      varchar2(20);
lx_return_status varchar2(50);
l_file          varchar2(100);
--
l_sql_string    varchar2(100) := 'ALTER SESSION SET SQL_TRACE TRUE';
p_id         NUMBER :=0;
osp_id       NUMBER :=0;
s_id         NUMBER :=0;

BEGIN

IF NOT l_trace_flag AND NOT l_log_flag THEN
--Bug : 1993476  Moved the following block up here so that it can print process ids etc when called from concurrent programs.
		BEGIN
                    EXECUTE IMMEDIATE l_sql_string;
-- Bug 1996039
                    l_sql_string := 'alter session set events '''||' 10046 trace name context forever, level 4 '''  ;
                    EXECUTE IMMEDIATE l_sql_string;

                    SELECT
                        SPID, S.AUDSID
                    INTO
                        osp_id, s_id
                    FROM
                        V$PROCESS P,
                        V$SESSION S
                    WHERE
                        S.AUDSID = USERENV('SESSIONID')
                    AND P.Addr = S.Paddr
                    AND rownum <= 1;

                EXCEPTION
                WHEN OTHERS THEN
                    NULL;
                END;

        g_request_id:=FND_GLOBAL.conc_request_id;
        IF g_request_id NOT IN (0, -1)   -- The conc. prog. is running
        THEN
                -- Sets up the log file for the conc.req
                set_trace_context(g_request_id, lx_return_status);
                IF lx_return_status = OKC_API.g_true THEN
                   l_log_flag    :=TRUE;
                   l_output_flag :=TRUE;
                ELSE
                   --We disregard the error and consider the trace mode is not
                   --activated, but cannot stop the user even if he requires a
                   --trace file
                   NULL;
                END IF;
        ELSE	-- Not a concurrent program
                -- Obtain the info to fill in the trace file
                SELECT  se.program
                       ,se.module      -- header and footer
                INTO    l_program
                       ,l_module
                FROM 	v$session         se
                       ,v$process        pr
                WHERE 	se.audsid = USERENV('SESSIONID')
                AND     se.paddr  = pr.addr;

                l_trace_flag := TRUE;

                -- Obtain the initial profile settings so that it can be reset later.

                l_init_profile_log_enabled := FND_PROFILE.VALUE('AFLOG_ENABLED');
                l_init_profile_module_level:= FND_PROFILE.VALUE('AFLOG_LEVEL');
                l_init_profile_module_name := FND_PROFILE.VALUE('AFLOG_MODULE');

                l_user_id := fnd_global.user_id; -- obtain the user ID

                IF l_user_id = -1       -- Non-Apps Mode.
                THEN
                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.g_session_id := sys_context('USERENV','SESSIONID');
                        END IF;

                        -- Set the profile values

                        FND_PROFILE.PUT('AFLOG_ENABLED','Y'); -- Enable the log
                        FND_PROFILE.PUT('AFLOG_LEVEL',1);     -- Set the debug level
                        FND_PROFILE.PUT('AFLOG_MODULE','OKC'); -- Set the module name
--
--In the Non-apps mode the value of g_profile_log_level in the okc_debug API
--is set to 0. However in the subsequent call to the Fnd_Log.test procedure
--the value of G_CURRENT_RUNTIME_LEVEL is used.Hence we need to set its value
--to 1 by executing the fnd_log_repository.init procedure call,as done below.
--Also, when the okc_util.print_trace is called it DOESNOT go through the
--looping in the set connection context procedure in the OKC_DEBUG package, so
--g_profile_log_level is never set and it is defaulted to 0
--

                        -- Initialize the current runtime level

                        FND_LOG_REPOSITORY.INIT(OKC_DEBUG.g_session_id,l_user_id);
-- Bug 1996039 Initializing aso debug
                        aso_debug_pub.debug_on;
                        aso_debug_pub.initialize;
                        l_file    :=aso_DEBUG_PUB.Set_Debug_Mode('FILE');
                        aso_Debug_pub.setdebuglevel(10);

                ELSE            -- Apps mode

--
--In the apps mode,the profile values are explicitly set and the
--fnd_log_repository.init procedure is invoked ,which sets the
--G_CURRENT_RUNTIME_LEVEL (based on profile option values)
--but since the set connection context is already
--executed (to run apps_initialize) and has set up g_profile_log_level,
--we need now to explicitly call fnd_log_repository.init to assign the
--new value of G_CURRENT_RUNTIME_LEVEL, which is then used to initialize
--g_profile_log_level value (p_level of okc_debug.log will be then greater
--or equal to g_profile_log_level)
--
                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.set_connection_context;
                        END IF;

                        FND_PROFILE.PUT('AFLOG_ENABLED','Y');
                        FND_PROFILE.PUT('AFLOG_LEVEL',1);
                        FND_PROFILE.PUT('AFLOG_MODULE','OKC');

                        FND_LOG_REPOSITORY.INIT(OKC_DEBUG.g_session_id,l_user_id);

                        IF (l_debug = 'Y') THEN
                           OKC_DEBUG.g_profile_log_level := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
                        END IF;
-- Bug 1996039 Initializing aso debug
                        aso_debug_pub.debug_on;
                        aso_debug_pub.initialize;
                        l_file    :=aso_DEBUG_PUB.Set_Debug_Mode('FILE');
                        aso_Debug_pub.setdebuglevel(10);


                END IF;

                -- Display the latest profile settings and other parameters


                -- Reset the profile values since the Initialization is already
                -- done (mandatory step in case our API is called by an external
                -- API which may have different settings from ours)

                        FND_PROFILE.PUT('AFLOG_ENABLED',l_init_profile_log_enabled);
                        FND_PROFILE.PUT('AFLOG_LEVEL',l_init_profile_module_level);
                        FND_PROFILE.PUT('AFLOG_MODULE',l_init_profile_module_name);

-- Set up the oracle trace enable to true and print out the DB trace file info

        END IF;
        --IF (l_trace_flag OR l_log_flag) AND NOT l_before_trace_flag THEN

           print_trace_header;

	       print_trace(0,'');
               print_trace(0,'');
               print_trace(0,'********** DATABASE TRACE INFORMATION***************');
               print_trace(0,'***** SESSION ID: '||s_id);
               print_trace(0,'***** ORACLE SERVER PROCESS ID '||osp_id);
               print_trace(0,'****************************************************');
               print_trace(0,'');
               print_trace(0,'');

        --END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'INIT_TRACE');
   OKC_API.set_message(G_APP_NAME
                      ,G_UNEXPECTED_ERROR
                      ,G_SQLCODE_TOKEN
                      ,SQLCODE
                      ,G_SQLERRM_TOKEN
                      ,SQLERRM);
   --RAISE; --Bug # 1850274
   l_log_flag    :=FALSE;
   l_output_flag :=FALSE;
   l_trace_flag  :=FALSE;
END init_trace;

------------------------------------------------------------------------------
--
-- Procedure:           stop_trace
-- Purpose:             Turn off the trace mode
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE stop_trace
IS

l_sql_string    varchar2(100) := 'ALTER SESSION SET SQL_TRACE FALSE';

BEGIN
   IF l_trace_flag AND NOT l_before_trace_flag THEN
--       reset_trace_context;
--        IF NOT l_before_trace_flag THEN
                print_trace_footer;
--        END IF;
         l_trace_flag           := FALSE;
   ELSIF l_log_flag AND NOT l_before_trace_flag THEN
         print_trace_footer;
         l_log_flag             := FALSE;
         l_output_flag          := FALSE;
         l_trace_file.id        := NULL;
         l_output_file.id       := NULL;
   END IF;
-- Bug 1996039 Stopping ASO debugg
   aso_debug_pub.debug_off;



  BEGIN
      EXECUTE IMMEDIATE l_sql_string;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'STOP_TRACE');
   OKC_API.set_message(G_APP_NAME
                      ,G_UNEXPECTED_ERROR
                      ,G_SQLCODE_TOKEN
                      ,SQLCODE
                      ,G_SQLERRM_TOKEN
                      ,SQLERRM);
   RAISE;
END stop_trace;

------------------------------------------------------------------------------
-- Procedure:           print_output
-- Purpose:             write a output line in the output file
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_output(p_indent     IN NUMBER,
                       p_trace_line IN VARCHAR2)
IS
l_mesg VARCHAR2(1900);
BEGIN
   IF l_output_flag AND l_output_file.id IS NOT NULL THEN
      l_mesg:=LPAD(p_trace_line, LENGTH(p_trace_line)+(4*p_indent), ' ');
      FND_FILE.PUT_LINE(l_output_file.id, l_mesg);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'PRINT_TRACE');
   RAISE;
END print_output;

-------------------------------------------------------------------------------
-- Procedure:           print_trace_header
-- Purpose:             print the standard header for trace files
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_trace_header
IS
BEGIN
   print_trace(0, '----------------------------------------------------------');
   print_trace(0, 'Trace activated');
   print_trace(0, 'Datetime            = ' || TO_CHAR(sysdate,'DD-MM HH24:MI:SS'));
-- print_trace(0, 'Trace location      = ' || l_trace_path);
-- print_trace(0, 'Trace file name     = ' || l_trace_file_name);
   print_trace(0, 'Program             = ' || l_program);
   print_trace(0, 'MODULE              = ' || l_module);
   print_trace(0, '----------------------------------------------------------');

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'PRINT_TRACE_HEADER');
   RAISE;
END print_trace_header;

-------------------------------------------------------------------------------
-- Procedure:           print_trace_footer
-- Purpose:             print the standard footer for trace files
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_trace_footer
IS
BEGIN
   print_trace(0, '----------------------------------------------------------');
   print_trace(0, 'Trace deactivated');
   print_trace(0, 'Datetime            = ' || TO_CHAR(sysdate,'DD-MM HH24:MI:SS'));
-- print_trace(0, 'Trace location      = ' || l_trace_path);
-- print_trace(0, 'Trace file name     = ' || l_trace_file_name);
   print_trace(0, 'Program             = ' || l_program);
   print_trace(0, 'MODULE              = ' || l_module);
   print_trace(0, '----------------------------------------------------------');

EXCEPTION
WHEN OTHERS THEN
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => 'OKC_K2Q_TRACE_MODE',
                       p_token1        => 'ACTION',
                       p_token1_value  => 'PRINT_TRACE_FOOTER');
   RAISE;
END print_trace_footer;

-------------------------------------------------------------------------------------------
-- Function     get_userenv_lang
-- Purpose:     See specs in OKCUTILS.pls
--              Briefly: This caches the value of userenv('lang') so
--              that subsequent calls do not result in a database hit
--              Partial Fix for Bug 1365356.
--
--
FUNCTION get_userenv_lang RETURN VARCHAR2  IS

BEGIN

-- Determine if this was determined before by examining the global
-- variable g_userenv_lang. If this is NOT null, return the value,
-- otherwise, determine the value, populate the global variable and
-- return the value.

  Set_Connection_Context;

  IF (g_userenv_lang IS NULL) Or (g_reset_lang_flag) Then
    g_userenv_lang := USERENV('LANG');
    g_reset_lang_flag := False;
  END IF;

  RETURN g_userenv_lang;

END get_userenv_lang;

-------------------------------------------------------------------------------------------
-- Function     get_prcnt
-- Purpose:     gets data from histogram

Function get_prcnt(
	p_owner varchar2,
	p_table varchar2,
	p_column varchar2,
	p_value varchar2) return number as
  l_startpoint number;
  l_endpoint number;
  l_percent number;
begin
  begin
    select max(ENDPOINT_NUMBER) into l_percent
    from all_histograms
    where owner=p_owner
    and TABLE_NAME=p_table
    and COLUMN_NAME=p_column;
  exception
    when others then l_percent := 0;
  end;
  if (l_percent=0 or l_percent is NULL) then return 0;
  end if;
  begin
    select ENDPOINT_NUMBER into l_endpoint
    from all_histograms
    where owner=p_owner
    and TABLE_NAME=p_table
    and COLUMN_NAME=p_column
    and ENDPOINT_VALUE=p_value;
  exception
    when others then return 0;
  end;
  if (l_endpoint=0 or l_endpoint is NULL) then return 0;
  end if;
  begin
    select max(ENDPOINT_NUMBER) into l_startpoint
    from all_histograms
    where owner=p_owner
    and TABLE_NAME=p_table
    and COLUMN_NAME=p_column
    and ENDPOINT_NUMBER<l_endpoint;
    exception
      when others then NULL;
  end;
  if (l_startpoint is NULL) then l_startpoint := 0;
  end if;
  return 100*(l_endpoint-l_startpoint)/l_percent;
end get_prcnt;

-------------------------------------------------------------------------------------------
-- Function     grp_dense
-- Purpose:     gets density from histogram for k groups
--		    returns 0 if small group, and 1 if not

Function grp_dense(p_grp_like varchar2) return number is
  d number;
  v number := fnd_profile.value('OKC_PERCENT_FOR_IDX');
begin
  select sum(OKC_UTIL.get_prcnt('OKC','OKC_K_GRPINGS','CGP_PARENT_ID',g.id)) into d
  from okc_k_groups_tl g
  where g.name like p_grp_like and g.language=userenv('LANG');
  if (d is NULL or d<=v) then return 0;
  else return 1;
  end if;
end;

---------------------------------------------------------------------------
function DECODE_LOOKUP (
--******************************************************************************
--* Returns the meaning for a lookup code of a specified type.
--******************************************************************************
--
        p_lookup_type   varchar2,
        p_lookup_code   varchar2) return varchar2 is
--
cursor csr_lookup is    -- /striping/ only for p_lookup_type = 'OKC_RULE_DEF'
        select meaning
        from    FND_LOOKUP_VALUES
        where   language = userenv('LANG')
        and     NVL(enabled_flag,'N') = 'Y'
        and     lookup_type     = p_lookup_type
        and     lookup_code     = p_lookup_code;

-- /striping/  -- only for p_lookup_type = 'OKC_RULE_DEF'
cursor csr_lookup1 is
        select meaning
        from    okc_rule_defs_v
        where   rule_code = p_lookup_code;

--
v_meaning       varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameters are going to retrieve anything
--
if p_lookup_type is not null and p_lookup_code is not null then
  --
-- /striping/
if p_lookup_type = 'OKC_RULE_DEF' then
  open csr_lookup1;
  fetch csr_lookup1 into v_meaning;
  close csr_lookup1;
else
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
end if;
  --
end if;
--
return v_meaning;
--
end decode_lookup;

---------------------------------------------------------------------------
  PROCEDURE Set_Search_String(p_srch_str      IN         VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    g_qry_clause := p_srch_str;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
  END;

  PROCEDURE Get_Search_String(
         x_srch_str OUT NOCOPY VARCHAR2) IS
  BEGIN
         x_srch_str := g_qry_clause;
  END;

-------------------------------------------------------------------------------
--Procedure is just a sample API that allows users to create their own
-- contract number. This procedure should be registered in the process
-- definition form and associated in the Auto Numbering setup screen before
-- it can be used to generate the contract number. This procedure can be
-- defined in any package and all the user has to do is to register it in
--the Process Definition Form.
------------------------------------------------------------------------------
  PROCEDURE generate_contract_number(
        x_contract_number OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
        x_contract_number := to_char(SYSDATE,'DDMMYYYYHHMISS');
        x_return_status := 'S';
  EXCEPTION
        WHEN OTHERS THEN
        x_return_status := 'U';
  END;

-------------------------------------------------------------------------
FUNCTION get_application_name ( p_application_id number) return varchar2
IS
CURSOR csr_appl_name IS
SELECT application_name
FROM fnd_application_vl
WHERE application_id = p_application_id;

l_application_name VARCHAR2(240):= NULL;

BEGIN

OPEN csr_appl_name;
  FETCH csr_appl_name INTO l_application_name;
CLOSE csr_appl_name;

 RETURN l_application_name;

END get_application_name;

-------------------------------------------------------------------------
function DECODE_LOOKUP_DESC (p_lookup_type varchar2, p_lookup_code varchar2) return varchar2
is
--******************************************************************************
--* Returns the description for a lookup code of a specified type.
--******************************************************************************
--
cursor csr_lookup is
select description
from    FND_LOOKUP_VALUES
where   language = userenv('LANG')
and     lookup_type     = p_lookup_type
and     lookup_code     = p_lookup_code;

v_description   varchar2(240) := null;

begin

if p_lookup_type is not null and p_lookup_code is not null then

  OPEN csr_lookup;
    FETCH csr_lookup INTO v_description;
  CLOSE csr_lookup;

end if;

return v_description;

end DECODE_LOOKUP_DESC;
-------------------------------------------------------------------------


---------------------------------------------------------------------------
---Funtion added to check if a user has access to a contract.  ---added for bug 9648125
----------------------------------------------------------------------------
FUNCTION ACCESS_ELIGIBLE (object_schema in varchar2, object_name varchar2) return varchar2 AS
BEGIN
      RETURN ' okc_util.get_k_access_level(OKC_K_HEADERS_B_ACCESS.id,OKC_K_HEADERS_B_ACCESS.scs_code) <>''N''';
 EXCEPTION WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'invoked', 'Error : '||SQLERRM);
  END IF;
END ACCESS_ELIGIBLE;

----------------------------------------------------------------------------
---Procedure to Prepare Contract Terms (dummy in 11.5.9, real for 11.5.10)
----------------------------------------------------------------------------
PROCEDURE Prepare_Contract_Terms(
    p_chr_id        IN NUMBER,
    x_doc_id        OUT NOCOPY NUMBER,
    x_doc_type      OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);
    l_tmpl_id    NUMBER;
    l_tmpl_name  VARCHAR2(100);
    l_start_date DATE;
    l_org_id     NUMBER;
    CURSOR start_date_crs IS
      SELECT start_date, authoring_org_id
        FROM OKC_K_HEADERS_B WHERE id=p_chr_id;
    CURSOR get_doc_usage_crs IS
      SELECT TEMPLATE_ID FROM okc_template_usages_v
       WHERE document_type = x_doc_type AND document_id = x_doc_id ;
    CURSOR get_apps_upg_tmpl_id_crs IS
      SELECT TEMPLATE_ID FROM okc_terms_templates_all
       WHERE template_name = l_tmpl_name and org_id=l_org_id;
 BEGIN
  IF (l_debug = 'Y') THEN
    okc_debug.log('11400: Entering Prepare_Contract_Terms ', 2);
  END IF;
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_id(
        p_api_version   => 1,
        x_return_status => x_return_status,
        x_msg_data      => l_msg_data,
        x_msg_count     => l_msg_count,
        p_chr_id        => p_chr_id,
        x_doc_id        => x_doc_id,
        x_doc_type      => x_doc_type
  );
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  OPEN get_doc_usage_crs;
  FETCH get_doc_usage_crs INTO l_tmpl_id;
  CLOSE get_doc_usage_crs;

  IF l_tmpl_id IS NULL THEN
    OPEN start_date_crs;
    FETCH start_date_crs INTO l_start_date, l_org_id;
    CLOSE start_date_crs;

    l_tmpl_name := x_doc_type || '_11510_UPG_TEMPLATE';

    OPEN get_apps_upg_tmpl_id_crs;
    FETCH get_apps_upg_tmpl_id_crs INTO l_tmpl_id;
    CLOSE get_apps_upg_tmpl_id_crs;

    IF l_tmpl_id IS NULL THEN
      SELECT OKC_TERMS_TEMPLATES_ALL_S.NEXTVAL
        INTO l_tmpl_id FROM DUAL;
      INSERT INTO OKC_TERMS_TEMPLATES_ALL(
        TEMPLATE_NAME,
        TEMPLATE_ID,
        WORKING_COPY_FLAG,
        INTENT,
        STATUS_CODE,
        START_DATE,
        GLOBAL_FLAG,
        CONTRACT_EXPERT_ENABLED,
        DESCRIPTION,
        ORG_ID,
        ORIG_SYSTEM_REFERENCE_CODE,
        HIDE_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        l_tmpl_name,
        l_tmpl_id,
        'N',
        Decode( x_doc_type,'OKC_BUY','B','OKE_BUY','B', 'S'),
        'APPROVED',
        to_date('01-01-1951','DD-MM-YYYY'),
        'N',
        'N',
        'Dummy Template for 11.5.10 Upgrade',
        l_org_id,
        decode (x_doc_type,'OKE_SELL', 'OKC11510UPG:OKE', 'OKE_BUY', 'OKC11510UPG:OKE', 'OKC11510UPG'),
        decode(x_doc_type,'OKS','N','Y'),
        1,
        Fnd_Global.User_Id,
        trunc(sysdate),
        Fnd_Global.User_Id,
        Fnd_Global.Login_Id,
        trunc(sysdate)
      );
   INSERT INTO OKC_ALLOWED_TMPL_USAGES(
        ALLOWED_TMPL_USAGES_ID,
        TEMPLATE_ID,
        DOCUMENT_TYPE,
        DEFAULT_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        OKC_ALLOWED_TMPL_USAGES_S.NEXTVAL,
        l_tmpl_id,
        x_doc_type,
        'N',
        1,
        Fnd_Global.User_Id,
        trunc(sysdate),
        Fnd_Global.User_Id,
        Fnd_Global.Login_Id,
        trunc(sysdate)
        );
    END IF;
    IF l_tmpl_id IS NOT NULL THEN
      OKC_TERMS_COPY_GRP.copy_terms(
        p_api_version   => 1,
        x_return_status => x_return_status,
        x_msg_data      => l_msg_data,
        x_msg_count     => l_msg_count,
        p_commit        => FND_API.G_TRUE,

        p_template_id            => l_tmpl_id,
        p_target_doc_type        => x_doc_type,
        p_target_doc_id          => x_doc_id,
        p_article_effective_date => l_start_date,
        p_validation_string      => NULL
      );
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;
  END IF;

  IF (l_debug = 'Y') THEN
    okc_debug.log('900: Leaving Prepare_Contract_Terms.', 2);
  END IF;

 EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving Prepare_Contract_Terms because of FND_API.G_EXC_UNEXPECTED_ERROR ', 2);
    END IF;

    IF get_doc_usage_crs%ISOPEN THEN
       CLOSE get_doc_usage_crs;
    END IF;

    IF get_apps_upg_tmpl_id_crs%ISOPEN THEN
       CLOSE get_apps_upg_tmpl_id_crs;
    END IF;

    IF start_date_crs%ISOPEN THEN
       CLOSE start_date_crs;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving Prepare_Contract_Terms because of FND_API.G_EXC_ERROR. ', 2);
    END IF;

    IF get_doc_usage_crs%ISOPEN THEN
       CLOSE get_doc_usage_crs;
    END IF;

    IF get_apps_upg_tmpl_id_crs%ISOPEN THEN
       CLOSE get_apps_upg_tmpl_id_crs;
    END IF;

    IF start_date_crs%ISOPEN THEN
       CLOSE start_date_crs;
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR ;

  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving Prepare_Contract_Terms because of EXCEPTION: '||sqlerrm, 2);
    END IF;

    IF get_doc_usage_crs%ISOPEN THEN
       CLOSE get_doc_usage_crs;
    END IF;

    IF get_apps_upg_tmpl_id_crs%ISOPEN THEN
       CLOSE get_apps_upg_tmpl_id_crs;
    END IF;

    IF start_date_crs%ISOPEN THEN
       CLOSE start_date_crs;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Prepare_Contract_Terms;



------------------------------------------------------------
--      Anonymous block for the package
--
-- This anonymous block is used to populate the global variable
-- g_language_code which contains the list of languages from
-- FND_LANGUAGES
------------------------------------------------------------

BEGIN

 SELECT  language_code
   BULK COLLECT INTO g_language_code
   FROM  fnd_languages
  WHERE  installed_flag IN ( 'I', 'B' );

END OKC_UTIL;

/
