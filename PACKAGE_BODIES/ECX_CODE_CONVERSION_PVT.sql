--------------------------------------------------------
--  DDL for Package Body ECX_CODE_CONVERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_CODE_CONVERSION_PVT" AS
-- $Header: ECXXREFB.pls 120.2 2006/05/24 16:34:17 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

PROCEDURE populate_plsql_tbl_with_extval
   (p_api_version_number   IN       NUMBER,
    p_init_msg_list        IN       VARCHAR2       := G_FALSE,
    p_simulate             IN       VARCHAR2       := G_FALSE,
    p_commit               IN       VARCHAR2       := G_FALSE,
    p_validation_level     IN       NUMBER         := G_VALID_LEVEL_FULL,
    p_standard_id          IN       NUMBER,
    p_return_status        OUT      NOCOPY         VARCHAR2,
    p_msg_count            OUT      NOCOPY         PLS_INTEGER,
    p_msg_data             OUT      NOCOPY         VARCHAR2,
    p_level                IN       PLS_INTEGER,
    p_tbl                  IN OUT   NOCOPY         ecx_utils.dtd_node_tbl,
    p_tp_id                IN       PLS_INTEGER) IS

    i_method_name   varchar2(2000) := 'ecx_code_conversion_pvt.populate_plsql_tbl_with_extval';

    l_api_name             CONSTANT VARCHAR2(30) := 'populate_plsql_tbl_with_extval';
    l_api_version_number   CONSTANT NUMBER       :=  1.0;

    l_msg_count            PLS_INTEGER;
    l_msg_data             VARCHAR2(2000);
    l_ext_val              VARCHAR2(4000) := NULL;
    l_var_value            VARCHAR2(4000) ;
    i                      PLS_INTEGER;
    xref_success           CONSTANT VARCHAR2(1) := 0;
    xref_warning           CONSTANT VARCHAR2(1) := 1;

    l_standard_id	  NUMBER;	/* Bug 2110362
					   The standard_id for the custom
					   standard. */
    l_univ_std_id         pls_integer;
    l_standard_type       Varchar2(200);

BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
    end if;
   if(l_statementEnabled) then
      ecx_debug.log(l_statement, 'API version : ',p_api_version_number,i_method_name);
      ecx_debug.log(l_statement, 'p_init_msg_list: ',p_init_msg_list,i_method_name);
      ecx_debug.log(l_statement, 'p_simulate: ',p_simulate,i_method_name);
      ecx_debug.log(l_statement, 'p_commit: ',p_commit,i_method_name);
      ecx_debug.log(l_statement, 'p_validation_level: ',p_validation_level,i_method_name);
  end if;

   -- Standard Start of API savepoint
   SAVEPOINT populate_plsql_tbl_ext_PVT;

   -- Initialize API return status to success
   p_return_status := g_ret_sts_success;

   begin
      select standard_type
      into   l_standard_type
      from   ecx_standards
      where  standard_id = p_standard_id;
   exception
      when others then
         l_standard_type := 'XML';
   end;

   /* Bug 2110362
   The Code conversion now has the following approach,
   1. Obtain standard id meant for the standard CUSTOM.
   2. Determine if code conversion is defined for CUSTOM.
      If yes, return the value defined.
   3. If No, determine if conversion is defined for the
      transaction's standard (based on p_standard) and return
      the value accordingly.					*/

   BEGIN
      SELECT  standard_id
      INTO    l_standard_id
      FROM    ecx_standards
      WHERE   standard_code = 'CUSTOM'
      and     standard_type = l_standard_type;
   EXCEPTION
      WHEN OTHERS THEN
	 l_standard_id := -1;
   END;

i := ecx_utils.g_source_levels(p_level).file_start_pos;
LOOP
   IF (ecx_utils.g_source(i).external_level = p_level) then
      if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'Interface Column Name', p_tbl(i).attribute_name,i_method_name);
      end if;

      if (p_tbl(i).is_clob is null) then
         if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Value before code conversion:', p_tbl(i).value,i_method_name);
	 end if;
         l_var_value := p_tbl(i).value;

         IF p_tbl(i).xref_category_id IS NOT NULL THEN
            BEGIN
               SELECT xref_ext_value
               INTO   l_ext_val
               FROM   ecx_xref_dtl
               WHERE  tp_header_id      = p_tp_id AND
                      xref_int_value    = p_tbl(i).value AND
                      standard_id       = l_standard_id AND
                      xref_category_id  = p_tbl(i).xref_category_id AND
                      direction         = 'OUT';

                p_tbl(i).value := nvl(l_ext_val,l_var_value);
                p_tbl(i).xref_retcode := xref_success;

            EXCEPTION
            WHEN no_data_found then
               null;
               BEGIN
                  SELECT xref_std_value
                  INTO  l_ext_val
                  FROM  ecx_xref_standards
                  WHERE standard_id = p_standard_id
                  AND   xref_category_id = p_tbl(i).xref_category_id
                  AND   xref_int_value = p_tbl(i).value;
                  if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'Using Standard Conversion',i_method_name);
		  end if;
                  p_tbl(i).value := nvl(l_ext_val,l_var_value);
                  p_tbl(i).xref_retcode := xref_success;
               EXCEPTION
               when no_data_found then
                  BEGIN
                     SELECT  standard_id
                     INTO    l_univ_std_id
                     FROM    ecx_standards
                     WHERE   standard_code = 'UNIVERSAL'
                     and     standard_type = l_standard_type;
                  EXCEPTION
                  WHEN OTHERS THEN
                     l_univ_std_id := -1;
                  END;
                  begin
                     SELECT xref_std_value
                     INTO  l_ext_val
                     FROM  ecx_xref_standards
                     WHERE standard_id = l_univ_std_id
                     AND   xref_category_id = p_tbl(i).xref_category_id
                     AND   xref_int_value = p_tbl(i).value;
                     if(l_statementEnabled) then
                      ecx_debug.log(l_statement,'Using Universal Conversion',i_method_name);
		     end if;
                     p_tbl(i).value := nvl(l_ext_val,l_var_value);
                     p_tbl(i).xref_retcode := xref_success;
                  EXCEPTION
                  /* Start of changes for Bug #2242061 */
                  WHEN TOO_MANY_ROWS THEN
                     if(l_unexpectedEnabled) then
                        ecx_debug.log(l_unexpected,'Data is Corrupted, Cannot resolve a unique' ||
                                  ' universal code conversion value for '||
                                  p_tbl(i).attribute_name, l_var_value,i_method_name);
		     end if;
                     p_tbl(i).value := l_var_value;
                     p_tbl(i).xref_retcode := xref_warning;
                     p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
                     /* End of changes for Bug #2242061 */
                  WHEN OTHERS THEN
                      p_tbl(i).value := l_var_value;
                      p_tbl(i).xref_retcode := xref_warning;
                      p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
                  END;
               /* Start of changes for Bug #2242061 */
               WHEN TOO_MANY_ROWS THEN
                  if(l_unexpectedEnabled) then
                      ecx_debug.log(l_unexpected, 'Data is Corrupted, Cannot resolve a unique' ||
                               ' standard code conversion value for '||
                                p_tbl(i).attribute_name, l_var_value,i_method_name);
	          end if;
                  p_tbl(i).value := l_var_value;
                  p_tbl(i).xref_retcode := xref_warning;
                  p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
               WHEN OTHERS THEN
                  p_tbl(i).value := l_var_value;
                  p_tbl(i).xref_retcode := xref_warning;
                  p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
               end;
            WHEN TOO_MANY_ROWS THEN
               if(l_unexpectedEnabled) then
                      ecx_debug.log(l_unexpected, 'Data is corrupted, Cannot resolve a unique custom code' ||
                          ' conversion value for' || p_tbl(i).attribute_name,l_var_value,i_method_name);
	       end if;
               p_tbl(i).value := l_var_value;
               p_tbl(i).xref_retcode := xref_warning;
               p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
            WHEN OTHERS THEN
               p_tbl(i).value := l_var_value;
               p_tbl(i).xref_retcode := xref_warning;
               p_return_status := ecx_code_conversion_PVT.g_xref_not_found;

             /* End of changes for Bug #2242061 */
            END;
         END IF;
          if(l_statementEnabled) then
             ecx_debug.log(l_statement, 'Value after code conversion:', p_tbl(i).value,i_method_name);
             ecx_debug.log(l_statement, 'Code conversion return code:', p_tbl(i).xref_retcode,i_method_name);
	  end if;
      END IF;
   END IF;
   EXIT WHEN i= ecx_utils.g_source_levels(p_level).file_end_pos;
   i := ecx_utils.g_source.next(i);
END LOOP;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
EXCEPTION
      WHEN g_exc_error THEN
         ROLLBACK TO populate_plsql_tbl_ext_PVT;
         p_return_status := g_ret_sts_error;
         if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
         end if;
      WHEN g_exc_unexpected_error THEN
         ROLLBACK TO populate_plsql_tbl_ext_PVT;
         p_return_status := g_ret_sts_error;
         if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
      WHEN OTHERS THEN
         ROLLBACK TO populate_plsql_tbl_ext_PVT;
         if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_CODE',i_method_name, 'ERROR_CODE',SQLCODE);
            ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
	 end if;
         p_return_status := g_ret_sts_error;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
END populate_plsql_tbl_with_extval;


PROCEDURE populate_plsql_tbl_with_intval
      (
   p_api_version_number    IN              NUMBER,
   p_init_msg_list         IN              VARCHAR2      := G_FALSE,
   p_simulate              IN              VARCHAR2      := G_FALSE,
   p_commit                IN              VARCHAR2      := G_FALSE,
   p_validation_level      IN              NUMBER        := G_VALID_LEVEL_FULL,
   p_standard_id           IN              NUMBER ,
   p_return_status         OUT    NOCOPY   VARCHAR2,
   p_msg_count             OUT    NOCOPY   PLS_INTEGER,
   p_msg_data              OUT    NOCOPY   VARCHAR2,
   p_level                 IN              PLS_INTEGER,
   p_apps_tbl              IN OUT NOCOPY   ecx_utils.dtd_node_tbl,
   p_tp_id                 IN              PLS_INTEGER
   ) IS

   i_method_name   varchar2(2000) := 'ecx_code_conversion_pvt.populate_plsql_tbl_with_intval';
    l_api_name            CONSTANT  VARCHAR2(30)  := 'populate_plsql_tbl_with_intval';
    l_api_version_number  CONSTANT  NUMBER        := 1.0;

    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    l_int_val             VARCHAR2(240) := NULL;
    l_var_value           VARCHAR2(500);
    j                     PLS_INTEGER;
    xref_success           CONSTANT VARCHAR2(1) := 0;
    xref_warning           CONSTANT VARCHAR2(1) := 1;

BEGIN
if (l_procedureEnabled) then
   ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'API version : ',p_api_version_number,i_method_name);
  ecx_debug.log(l_statement, 'p_init_msg_list: ',p_init_msg_list,i_method_name);
  ecx_debug.log(l_statement, 'p_simulate: ',p_simulate,i_method_name);
  ecx_debug.log(l_statement, 'p_commit: ',p_commit,i_method_name);
  ecx_debug.log(l_statement, 'p_validation_level: ',p_validation_level,i_method_name);
end if;
         -- Standard Start of API savepoint
      SAVEPOINT populate_plsql_tbl_int_PVT;

   -- Initialize API return status to success
   p_return_status := g_ret_sts_success;

j := ecx_utils.g_source_levels(p_level).file_start_pos;
LOOP
    IF (ecx_utils.g_source(j).external_level = p_level) THEN
      if(l_statementEnabled) then
         ecx_debug.log(l_statement,'Interface Column Name', p_apps_tbl(j).attribute_name,i_method_name);
         ecx_debug.log(l_statement, 'Value before code conversion:', p_apps_tbl(j).value,i_method_name);
      end if;
      l_var_value := p_apps_tbl(j).value;

      IF l_var_value IS NULL THEN
         p_apps_tbl(j).value := l_var_value;
      ELSIF p_apps_tbl(j).xref_category_id IS NOT NULL THEN
         BEGIN
            SELECT xref_int_value
              INTO l_int_val
              FROM ecx_xref_dtl
             WHERE tp_header_id = p_tp_id AND
                   standard_id  =  p_standard_id AND
                   xref_category_id = p_apps_tbl(j).xref_category_id AND
                   xref_ext_value     = p_apps_tbl(j).value AND
                   direction = 'IN';
            p_apps_tbl(j).value := l_int_val;
            p_apps_tbl(j).xref_retcode := xref_success;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              if(l_unexpectedEnabled) then
                ecx_debug.log(l_unexpected, 'Using Standard Conversion',i_method_name);
              end if;
               null;
              BEGIN
                 SELECT xref_std_value
                 INTO  l_int_val
                 FROM  ecx_xref_standards
                 WHERE standard_id = p_standard_id
                 AND   xref_category_id = p_apps_tbl(j).xref_category_id
                 AND   xref_int_value = p_apps_tbl(j).value;

                p_apps_tbl(j).value := nvl(l_int_val,l_var_value);
                p_apps_tbl(j).xref_retcode := xref_success;
              EXCEPTION
              WHEN OTHERS THEN
                 p_apps_tbl(j).value := l_var_value;
                 p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
                 p_apps_tbl(j).xref_retcode := xref_warning;
              END;
         END;
      END IF;

      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, 'Value after code conversion:', p_apps_tbl(j).value,i_method_name);
          ecx_debug.log(l_unexpected, 'Code conversion return code:', p_apps_tbl(j).xref_retcode,i_method_name);
      end if;
   END IF;

   EXIT WHEN j= ecx_utils.g_source_levels(p_level).file_end_pos;
   j := ecx_utils.g_source.next(j);
END LOOP;

   -- *******************************************************
   -- Standard check of p_simulate and p_commit parameters
   -- *******************************************************

if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;

EXCEPTION
WHEN g_exc_error THEN
      ROLLBACK TO populate_plsql_tbl_int_PVT;
      p_return_status := g_ret_sts_error;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
WHEN G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO populate_plsql_tbl_int_PVT;
      p_return_status := g_ret_sts_error;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_CODE',i_method_name,'ERROR_CODE',SQLCODE);
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ROLLBACK TO populate_plsql_tbl_int_PVT;
      p_return_status := g_ret_sts_error;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
END populate_plsql_tbl_with_intval;

PROCEDURE convert_external_value
        (
        p_api_version_number    IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2      := G_FALSE,
        p_simulate              IN              VARCHAR2      := G_FALSE,
        p_commit                IN              VARCHAR2      := G_FALSE,
        p_validation_level      IN              NUMBER        := G_VALID_LEVEL_FULL,
        p_standard_id           IN              NUMBER,
        p_return_status         OUT    NOCOPY   VARCHAR2,
        p_msg_count             OUT    NOCOPY   PLS_INTEGER,
        p_msg_data              OUT    NOCOPY   VARCHAR2,
        p_value                 IN OUT NOCOPY   VARCHAR2,
        p_category_id           IN              PLS_INTEGER,
        p_snd_tp_id             IN              PLS_INTEGER,
        p_rec_tp_id             IN              PLS_INTEGER
        ) IS


i_method_name   varchar2(2000) := 'ecx_code_conversion_pvt.convert_external_value';

    l_api_name            CONSTANT  VARCHAR2(30)  := 'convert_external_value';
    l_api_version_number  CONSTANT  NUMBER        := 1.0;

    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_int_val             VARCHAR2(4000) := NULL;
    l_ext_val             VARCHAR2(4000) := NULL;
    l_var_value           VARCHAR2(4000);
    l_standard_id	  NUMBER;	/* Bug 2110362
					   The standard_id for the custom
					   standard. */
    l_univ_std_id         pls_integer;
    l_standard_type       varchar2(200);

BEGIN
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'API version : ',p_api_version_number,i_method_name);
  ecx_debug.log(l_statement, 'p_value: ',p_value,i_method_name);
  ecx_debug.log(l_statement, 'p_category_id: ',p_category_id,i_method_name);
  ecx_debug.log(l_statement, 'p_snd_tp_id: ',p_snd_tp_id,i_method_name);
  ecx_debug.log(l_statement, 'p_rec_tp_id: ',p_rec_tp_id,i_method_name);
end if;

        -- Standard Start of API savepoint
        SAVEPOINT populate_value_extpt_PVT;

      -- Initialize API return status to success
        p_return_status := g_ret_sts_success;

        if(l_statementEnabled) then
          ecx_debug.log(l_statement,'Value before code conversion:', p_value,i_method_name);
	end if;
	l_var_value := p_value;

        begin
           select standard_type
           into   l_standard_type
           from   ecx_standards
           where  standard_id = p_standard_id;
        exception
           when others then
              l_standard_type := 'XML';
        end;

        /* Bug 2110362
	   The Code conversion now has the following approach,
	   1. Obtain standard id meant for the standard CUSTOM.
	   2. Determine if code conversion is defined for CUSTOM.
  	      If yes, return the value defined.
	   3. If No, determine if conversion is defined for the
	      transaction's standard (based on p_standard) and return
	      the value accordingly.					*/

	BEGIN
	   SELECT  standard_id
	   INTO	   l_standard_id
	   FROM	   ecx_standards
	   WHERE   standard_code = 'CUSTOM'
           and     standard_type = l_standard_type;
	EXCEPTION
	   WHEN OTHERS THEN
	      l_standard_id := -1;
	END;

        IF p_value IS NOT NULL THEN
          BEGIN
		  /* Bug 2110362
		     Replaced reference to p_standard_id with l_standard_id. */
         	  SELECT  xref_int_value
                   INTO   l_int_val
                   FROM   ecx_xref_dtl
                   WHERE  tp_header_id = p_snd_tp_id AND
                          standard_id    =  l_standard_id AND
                          xref_category_id = p_category_id AND
                          xref_ext_value     = p_value AND
                          direction = 'IN';
                          p_return_status := 0;
                        EXCEPTION
                                WHEN no_data_found then
                                begin
                                  SELECT xref_int_value
                                  INTO  l_int_val
                                  FROM  ecx_xref_standards
                                  WHERE standard_id = p_standard_id
                                  AND   xref_category_id = p_category_id
                                  AND   xref_std_value = rtrim(p_value);
                                  p_return_status := 0;
                                exception
                                  when no_data_found then
                                     BEGIN
                                        SELECT  standard_id
                                        INTO    l_univ_std_id
                                        FROM    ecx_standards
                                        WHERE   standard_code = 'UNIVERSAL'
                                        and     standard_type = l_standard_type;
                                     EXCEPTION
                                     WHEN OTHERS THEN
                                        l_univ_std_id := -1;
                                     END;
                                     begin
                                        SELECT xref_int_value
                                        INTO  l_int_val
                                        FROM  ecx_xref_standards
                                        WHERE standard_id = l_univ_std_id
                                        AND   xref_category_id = p_category_id
                                        AND   xref_std_value = rtrim(p_value);
                                        p_return_status := 0;
                                     exception
                                     when others then
                                        p_return_status := ecx_code_conversion_PVT.g_xref_not_found;
                                        p_value := l_var_value;
                                        l_int_val := l_var_value;
                                        --ecx_debug.pop('ecx_code_conversion_PVT.convert_external_value');
                                        --return;
                                     end;
                                end;

          END;
                p_value := l_int_val;
		if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'Value after ext to int code conversion:', p_value,i_method_name);
		end if;

          	IF (l_int_val IS NOT NULL AND p_rec_tp_id IS NOT NULL) THEN
                     BEGIN
		        /* Bug 2110362
		           Replaced reference to p_standard_id with
			   l_standard_id. */
         		SELECT xref_ext_value
                        INTO   l_ext_val
                        FROM   ecx_xref_dtl
                        WHERE  tp_header_id = p_rec_tp_id AND
                               standard_id = l_standard_id AND
                               xref_category_id = p_category_id AND
                               xref_int_value     = l_int_val AND
                               direction = 'OUT';
                               p_return_status := 0;
                        EXCEPTION
                                WHEN no_data_found then
                                begin
                                  SELECT xref_std_value
                                  INTO  l_ext_val
                                  FROM  ecx_xref_standards
                                  WHERE standard_id = p_standard_id
                                  AND   xref_category_id = p_category_id
                                  AND   xref_int_value = p_value;
                                  p_return_status := 0;
                                exception
                                  when no_data_found then
                                     begin
                                        SELECT xref_std_value
                                        INTO  l_ext_val
                                        FROM  ecx_xref_standards
                                        WHERE standard_id = l_univ_std_id
                                        AND   xref_category_id = p_category_id
                                        AND   xref_int_value = p_value;
                                        p_return_status := 0;
                                     exception
                                     when others then
                                        p_return_status := ecx_code_conversion_PVT.g_recv_xref_not_found;
                                        if (l_procedureEnabled) then
						ecx_debug.pop(i_method_name);
                                        end if;
                                        return;
                                     end;
                                end;

                      END;
			p_value := l_ext_val;
			if(l_unexpectedEnabled) then
                         ecx_debug.log(l_unexpected, 'Value after int to ext code conversion:',
			              p_value,i_method_name);
		        end if;
		 END IF;
         END IF;
	if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'Value after code conversion:', p_value,i_method_name);
	end if;


        -- *******************************************************
        -- Standard check of p_simulate and p_commit parameters
        -- *******************************************************

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
EXCEPTION
WHEN g_exc_error THEN
        ROLLBACK TO populate_value_extpt_PVT;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
        p_return_status := g_ret_sts_error;
WHEN g_exc_unexpected_error THEN
        ROLLBACK TO populate_value_extpt_PVT;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
        p_return_status := g_ret_sts_error;
WHEN OTHERS THEN
         if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_CODE',i_method_name,'ERROR_CODE',SQLCODE);
            ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
	 end if;
         ROLLBACK TO populate_value_extpt_PVT;
         if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
         p_return_status := g_ret_sts_error;
END convert_external_value;

END ecx_code_conversion_PVT;

/
