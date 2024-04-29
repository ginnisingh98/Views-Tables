--------------------------------------------------------
--  DDL for Package Body ZX_TPI_PLUGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TPI_PLUGIN_PKG" AS
/* $Header: zxisrvctypcgpvtb.pls 120.6 2006/08/14 23:47:50 svaze ship $ */

/* ---------------------------------------------------------------------------*/
/*          Declaration of Local Variable declaration                         */
/* ---------------------------------------------------------------------------*/
    l_pack_name         VARCHAR2(1000);
    l_string            VARCHAR2(4000);
    l_first             BOOLEAN;
    l_switch_mode       BOOLEAN;
    l_no_of_strings     Binary_integer;
    l_count             binary_integer;
    l_prvidx            BINARY_INTEGER;
    l_srvcidx           Binary_integer;
    l_apiidx            Binary_integer;
    l_break             BOOLEAN;
    dummy               VARCHAR2(2000);
    dummy_body          VARCHAR2(2000);
    l_exists            VARCHAR2(1);
/* -------------------------------------------------------------------------- */
/*  Cursors to select api owners for that service category                    */
/* -------------------------------------------------------------------------- */

    Cursor c_apiowner(p_srvc_cat IN VARCHAR2,p_api_owner_id IN NUMBER) is
      SELECT distinct api_owner_id
           , status_code
      FROM zx_api_owner_statuses
      WHERE upper(service_category_code) = upper(p_srvc_cat)
      AND api_owner_id = nvl(p_api_owner_id, api_owner_id)
      ORDER BY api_owner_id asc;

/* -------------------------------------------------------------------------- */
/*  Cursor to select distinct service types for that service category         */
/* -------------------------------------------------------------------------- */

    Cursor c_srvctyp(p_srvc_cat IN VARCHAR2,p_api_owner_id IN NUMBER) is
      SELECT distinct a.api_owner_id
           , b.service_type_id
           , b.service_type_code
           , b.data_transfer_code
      FROM  zx_api_registrations a
          , zx_service_types b
          , zx_api_owner_statuses c
      WHERE a.service_type_id = b.service_type_id
      AND   a.api_owner_id = c.api_owner_id
      AND   upper(c.service_category_code) = upper(p_srvc_cat)
      AND   a.api_owner_id = nvl(p_api_owner_id,a.api_owner_id)
      ORDER BY a.api_owner_id asc
             , b.data_transfer_code desc
             , b.service_type_id asc;

/* -------------------------------------------------------------------------- */
/*  Cursor to select distinct context ids for that service category           */
/* -------------------------------------------------------------------------- */

    Cursor c_api(p_srvc_cat IN VARCHAR2,p_api_owner_id IN NUMBER) is
      SELECT distinct a.api_owner_id
           , a.service_type_id
           , a.context_ccid
           , a.package_name
           , a.procedure_name
           , b.service_type_code
      FROM   zx_api_registrations a
           , zx_service_types b
           , zx_api_owner_statuses c
      WHERE  a.service_type_id = b.service_type_id
      and    a.api_owner_id = c.api_owner_id
      and    upper(c.service_category_code) = upper(p_srvc_cat)
      and    a.api_owner_id = nvl(p_api_owner_id, a.api_owner_id)
      ORDER BY a.api_owner_id asc
             , b.service_type_code asc
             , a.context_ccid asc;

/* -------------------------------------------------------------------------- */
/*      Procedure to increment the counter                                    */
/* -------------------------------------------------------------------------- */

     PROCEDURE Increment_counter IS
       BEGIN

         g_counter := g_counter + 1;

       END;

/* -------------------------------------------------------------------------- */
/*      Procedure to print the strings                                        */
/* -------------------------------------------------------------------------- */

     PROCEDURE print_string(p_str IN VARCHAR2) IS
       BEGIN

         ad_ddl.build_statement(p_str,g_counter);
         increment_counter;
--         dbms_output.put_line(p_str);
         Fnd_file.put_line(FND_FILE.log,p_str);
       END;

/* -------------------------------------------------------------------------- */
/*      Procedure to print debug messages                                     */
/* -------------------------------------------------------------------------- */

     PROCEDURE print_debug(p_str IN VARCHAR2) IS
       BEGIN

--         dbms_output.put_line(p_str);
         Fnd_file.put_line(FND_FILE.log,p_str);
       END;

/* -------------------------------------------------------------------------- */
/*      Procedure to insert global variables for debug                        */
/*      Bug # 4769082                                                         */
/* -------------------------------------------------------------------------- */

     PROCEDURE insert_gbl_var_for_debug(p_string IN VARCHAR2) IS
       BEGIN
          l_string := '/* Global Data Types */';
          print_string(l_string);

          l_string := 'G_PKG_NAME              CONSTANT VARCHAR2(80) := ''';
          l_string := l_string || p_string || ''';';
          print_string(l_string);

          l_string := 'G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;';
          print_string(l_string);

          l_string := 'G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;';
          print_string(l_string);

          l_string := 'G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;';
          print_string(l_string);

          l_string := 'G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;';
          print_string(l_string);

          l_string := 'G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;';
          print_string(l_string);

          l_string := 'G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;';
          print_string(l_string);

          l_string := 'G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;';
          print_string(l_string);

          l_string := 'G_MODULE_NAME           CONSTANT VARCHAR2(80) := ''';
          l_string := l_string || 'ZX.PLSQL.' || p_string || '.'';';
          print_string(l_string);

       END insert_gbl_var_for_debug;

/* -------------------------------------------------------------------------- */
/*      Procedure to insert debug statement                                   */
/*      Bug # 4769082                                                         */
/* -------------------------------------------------------------------------- */

     PROCEDURE insert_debug(  p_stmt_type IN VARCHAR2
                            , p_str IN VARCHAR2) IS
       BEGIN
          l_string := 'IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN';
          print_string(l_string);

          IF p_stmt_type = 'BEGIN' THEN
             l_string := 'FND_LOG.STRING(G_LEVEL_PROCEDURE';
             print_string(l_string);
             l_string := ',G_MODULE_NAME || l_api_name ||';
--           l_string := l_string || '''-BEG''';
             l_string := l_string || '''.BEGIN''';
             print_string(l_string);
             l_string := ',G_PKG_NAME||' ||''': '''|| '||l_api_name||' ||'''()+'||''');';
             print_string(l_string);
          ELSE
             l_string := 'FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name';
             l_string := l_string || ', ''' || p_str || ''');';
             print_string(l_string);
          END IF;

          l_string := 'END IF;';
          print_string(l_string);

       END;

/* -------------------------------------------------------------------------- */
/*      Procedure get_srvc_typ_params to get the parameter string             */
/* -------------------------------------------------------------------------- */

      PROCEDURE get_srvc_typ_params ( p_srvc_typ_id        IN NUMBER,
                                      p_service_type_code  IN VARCHAR2,
                                      p_data_transfer_code IN VARCHAR2,
                                      p_location           IN VARCHAR2,
                                      p_package_name       IN VARCHAR2,
                                      p_procedure_name     IN VARCHAR2,
                                      x_param_string_tbl   OUT NOCOPY t_srvcparamtbl,
                                      x_no_of_strings      OUT NOCOPY BINARY_INTEGER,
                                      x_return_status      OUT NOCOPY  VARCHAR2) IS

      CURSOR c_params IS
        SELECT service_type_id,
               parameter_name,
               position,
               param_usage_code,
               map_global_var_code,
               map_gbl_var_data_type
        FROM   zx_srvc_typ_params
        WHERE   service_type_id = p_srvc_typ_id;

      l_stp_first       BOOLEAN;
      l_param_string    VARCHAR2(255);
      l_counter         BINARY_INTEGER;
      l_return_status   VARCHAR2(1);
      BEGIN
         print_debug('--  CG: get_srvc_typ_params(+)');
         print_debug('--  CG: p_location = '||p_location);
         print_debug('--  CG: p_srvc_typ_id = '||to_char(p_srvc_typ_id));
         print_debug('--  CG: p_service_type_code = '||p_service_type_code);
         print_debug('--  CG: p_data_transfer_code = '||p_data_transfer_code);
         l_stp_first   := TRUE;
         l_counter := 0;
         FOR rec IN c_params LOOP

             IF p_location = 'HEADER' THEN
               l_param_string := ltrim(rtrim(rec.parameter_name)) || ' '
                              || ltrim(rtrim(rec.param_usage_code))||' '
                              || ltrim(rtrim(rec.map_gbl_var_data_type));
               IF l_stp_first THEN
                  x_param_string_tbl(l_counter) := 'PROCEDURE ' || p_service_type_code
                                 || '( p_context_ccid IN NUMBER';
                  l_counter := l_counter + 1;
                  l_stp_first := FALSE;
               END IF;
               l_param_string := ', ' || l_param_string;
             END IF;

             IF p_location = 'CALL' THEN
               l_param_string := rec.map_global_var_code;
               IF l_stp_first THEN
                  x_param_string_tbl(l_counter) := p_service_type_code
                                 || '( p_context_ccid';
                  l_counter := l_counter + 1;
                  l_stp_first := FALSE;
               END IF;
                  l_param_string := ', ' || l_param_string;
             END IF;

             IF p_location = 'PARTNER'  THEN
               l_param_string := rec.parameter_name;
               IF l_stp_first THEN
                  l_param_string := p_package_name || '.'
                                 || p_procedure_name || '('
                                 || l_param_string;
                  l_stp_first := FALSE;
               ELSE
                  l_param_string := ', ' || l_param_string;
               END IF;
             END IF;

             IF rec.parameter_name = 'ERROR_STATUS' THEN
                g_rtn_status_var := rec.map_global_var_code;
             END IF;

             IF rec.parameter_name = 'ERROR_DEBUG_MSG_TBL' THEN
                g_rtn_msgtbl_var := rec.map_global_var_code;
             END IF;

             x_param_string_tbl(l_counter) := l_param_string ;
             l_counter := l_counter + 1;

           End Loop;

        IF p_location = 'HEADER' THEN
           l_param_string := ') IS';
        ELSE
           l_param_string := ');';
        END IF;
        x_param_string_tbl(l_counter) := l_param_string ;
        x_no_of_strings := l_counter;

         print_debug('--  CG: get_srvc_typ_params(-)');
      EXCEPTION
        WHEN OTHERS THEN
          print_debug('--  CG: sqlerrm = '||sqlerrm);
          x_return_status := FND_API.G_RET_STS_ERROR;
      END get_srvc_typ_params;


      PROCEDURE create_third_party_pkg_spec
      IS

      BEGIN
        l_string := 'CREATE OR REPLACE PACKAGE '||l_pack_name||' AS';
        print_string(l_string);

        l_string := 'PROCEDURE main_router (p_srvc_type_id IN NUMBER';
        print_string(l_string);
        l_string := ', p_context_ccid IN NUMBER';
        print_string(l_string);
        l_string := ', p_data_transfer_code IN VARCHAR2';
        print_string(l_string);
        l_string := ', x_return_status OUT NOCOPY VARCHAR2);';
        print_string(l_string);

        l_string :=  'END '||l_pack_name||' ;';
        print_string(l_string);

        ad_ddl.create_plsql_object(
        'APPS','ZX',l_pack_name,1,(g_counter-1),'TRUE',dummy);

      END create_third_party_pkg_spec;
/*------------------------------------------------------------------------*/
/*   Creating the individual package body for the api owner               */
/*------------------------------------------------------------------------*/

      PROCEDURE create_main_router_body (p_prvidx        IN NUMBER)
      IS

      l_pls               BOOLEAN;
      l_return_status     VARCHAR2(1);
      BEGIN

        l_string := 'PROCEDURE MAIN_ROUTER (p_srvc_type_id IN NUMBER';
        print_string(l_string);
        l_string := ', p_context_ccid IN NUMBER';
        print_string(l_string);
        l_string := ', p_data_transfer_code IN VARCHAR2';
        print_string(l_string);
        l_string := ', x_return_status OUT NOCOPY VARCHAR2';
        print_string(l_string);
        l_string := ') IS';
        print_string(l_string);

        l_string := 'InvalidServiceType Exception;';
        print_string(l_string);

        l_string := 'InvalidDataTransferMode Exception;';
        print_string(l_string);

        l_string := 'l_api_name  CONSTANT VARCHAR2(80) := ''MAIN_ROUTER'';';
        print_string(l_string);

        l_string :=  '  BEGIN ';
        print_string(l_string);

        insert_debug('BEGIN', NULL);

        l_string := 'x_return_status := FND_API.G_RET_STS_SUCCESS;';
        print_string(l_string);

        l_first := TRUE;

        l_break := FALSE;

/* -------------------------------------------------------------------------- */
/*  Check to see if the individual data transfer mode is PLS                  */
/* -------------------------------------------------------------------------- */

-- l_pls is for the first iteration

        l_pls := TRUE;

        FOR l_srvcidx in  1..(nvl(t_srvc.api_owner_id.LAST,0)) LOOP

          IF (t_srvc.api_owner_id(l_srvcidx) = t_prv.api_owner_id(p_prvidx)) THEN

            l_break := TRUE;

            l_switch_mode := TRUE;

            IF ( t_srvc.data_transfer_code(l_srvcidx) = 'PLS' and l_pls ) THEN

              l_string := ' IF p_data_transfer_code = ''PLS'' THEN ';

              print_string(l_string);

              l_pls := FALSE;

/* -------------------------------------------------------------------------- */
/*  IF the data transfer Mode is GTT then switch                              */
/* -------------------------------------------------------------------------- */

            ELSIF ( t_srvc.data_transfer_code(l_srvcidx) = 'GTT' AND l_switch_mode) THEN

              l_string :=  'ELSE ';
              print_string(l_string);

              l_string := ' Raise InvalidServiceType;  ';
              print_string(l_string);

              l_string := 'END IF; ';
              print_string(l_string);

              l_string := 'ELSIF p_data_transfer_code = ''GTT'' THEN ';
              print_string(l_string);

              l_first := TRUE;
              l_switch_mode := FALSE;

            END IF;

/* -------------------------------------------------------------------------- */
/*  Giving a call to get_srvc_typ_params to get the parameters for the service*/
/*  type                                                                      */
/* -------------------------------------------------------------------------- */
            get_srvc_typ_params ( t_srvc.service_type_id(l_srvcidx),
                                  t_srvc.service_type_code(l_srvcidx),
                                  t_srvc.data_transfer_code(l_srvcidx),
                                  'CALL',
                                  NULL,
                                  NULL,
                                  r_srvcparamtbl,
                                  l_no_of_strings,
                                  l_return_status);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              print_debug('Parameter data not seeded for Service type Id '||to_char(t_srvc.service_type_id(l_srvcidx)));

              EXIT;

            END IF;

            IF l_first THEN

              l_string := '  IF p_srvc_type_id = '''||to_char(t_srvc.service_type_id(l_srvcidx))||''' THEN ';
              print_string(l_string);

              l_first := FALSE;

            ELSE

              l_string := ' ELSIF p_srvc_type_id = '''||to_char(t_srvc.service_type_id(l_srvcidx))||''' THEN ';
              print_string(l_string);

            END IF;

            FOR i in 0..l_no_of_strings LOOP
                l_string := r_srvcparamtbl(i);
                print_string(l_string);
            END LOOP;

            IF g_rtn_status_var is NOT NULL THEN
              l_string :=
            ' IF '||g_rtn_status_var||' <> FND_API.G_RET_STS_SUCCESS THEN ';
              print_string(l_string);

             l_string := ' x_return_status := FND_API.G_RET_STS_ERROR;';
              print_string(l_string);

             l_string := ' Return ;';
              print_string(l_string);

             l_string := ' END IF ;';
              print_string(l_string);

           END IF;

          END IF;

          IF ((t_srvc.api_owner_id(l_srvcidx) <> t_prv.api_owner_id(p_prvidx)) AND l_break ) THEN

            EXIT;

          END IF;

        END Loop;

          l_string := 'ELSE ';
           print_string(l_string);

         l_string :=  ' Raise InvalidServiceType;  ';
           print_string(l_string);

          l_string :=  'END IF; ';
           print_string(l_string);

          l_string :=
          'ELSE ';
           print_string(l_string);

          l_string :=  'Raise Invaliddatatransfermode;';
           print_string(l_string);

          l_string :=  'END IF; ';
           print_string(l_string);

          l_string := 'EXCEPTION ';
           print_string(l_string);

          l_string :=  'WHEN InvalidServiceType THEN ';
           print_string(l_string);

          l_string := 'FND_MESSAGE.SET_NAME(''ZX'',''ZX_INVALID_SERVICE_TYPE'');';
           print_string(l_string);

          l_string := 'FND_MSG_PUB.ADD; ';
           print_string(l_string);

         l_string := 'Return ; ';
           print_string(l_string);

          l_string := 'WHEN InvalidDataTransferMode THEN ';
           print_string(l_string);

          l_string := 'FND_MESSAGE.SET_NAME(''ZX'',''ZX_INVALID_data_transfer_code'');';
           print_string(l_string);

          l_string := 'FND_MSG_PUB.ADD; ';
           print_string(l_string);

          l_string := 'Return ; ';
           print_string(l_string);

          l_string := 'END main_router;';
           print_string(l_string);

      END create_main_router_body;
/*--------------------------------------------------------------*/
/*                              Main                            */
/*--------------------------------------------------------------*/
PROCEDURE generate_code(
errbuf           OUT NOCOPY VARCHAR2,
retcode          OUT NOCOPY VARCHAR2,
p_srvc_category  IN         VARCHAR2,
p_api_owner_id   IN         NUMBER
) IS
    l_return_status            VARCHAR2(1);
    l_exists_in_owner_statuses VARCHAR2(1);
    l_api_owner_id_char        VARCHAR2(30);
BEGIN
/*-----------------------------------------------------------------------*/
/*  If the code is to be generated for main wrapper package for service  */
/*  category                                                             */
/*-----------------------------------------------------------------------*/
  Begin
    SELECT 'Y' into l_exists
    FROM dual
    WHERE exists
    ( SELECT api_owner_id
      FROM zx_api_owner_statuses
      WHERE
      status_code in ('DELETED','NEW')
    );
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
     l_exists := 'N';
    END;

  retcode := FND_API.G_RET_STS_SUCCESS ;


   --Initialize;
/* -------------------------------------------------------------------------- */
/*    Fetching the individual cursors into record of tables.                  */
/* -------------------------------------------------------------------------- */

   IF p_api_owner_id is NOT NULL THEN
      l_exists_in_owner_statuses := 'Y';
      BEGIN
         SELECT 'Y'
           INTO l_exists_in_owner_statuses
           FROM zx_api_owner_statuses
          WHERE upper(service_category_code) = upper(p_srvc_category)
          AND   api_owner_id = p_api_owner_id;
      EXCEPTION
          WHEN OTHERS THEN
               l_exists_in_owner_statuses := 'N';
      END;

      IF l_exists_in_owner_statuses = 'N' THEN
         print_debug('--  CG: Inserting a record in zx_api_owner_statuses for API owners');
         INSERT INTO zx_api_owner_statuses(api_owner_id
                                        , service_category_code
                                        , status_code
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login)
                                   values(p_api_owner_id
                                        , p_srvc_category
                                        , 'NEW'
                                        , sysdate
                                        , fnd_global.user_id
                                        , sysdate
                                        , fnd_global.user_id
                                        , fnd_global.user_id);
      END IF;

   END IF;

   Open c_apiowner(p_srvc_category,p_api_owner_id);

       print_debug('--  CG: Opening for API owners');

       LOOP
         FETCH c_apiowner BULK COLLECT INTO
               t_prv.api_owner_id,
               t_prv.status_code;
         EXIT WHEN c_apiowner%NOTFOUND;
       END LOOP;

       print_debug('--  CG: Closing for API owners');
   Close c_apiowner;

   Open c_srvctyp(p_srvc_category,p_api_owner_id);

         print_debug('--  CG: Opening for service types');

   LOOP

     FETCH c_srvctyp BULK COLLECT INTO
     t_srvc.api_owner_id,
     t_srvc.service_type_id,
     t_srvc.service_type_code,
     t_srvc.data_transfer_code;

     EXIT WHEN c_srvctyp%NOTFOUND;

   END LOOP;

   IF c_srvctyp%ROWCOUNT = 0 THEN
      print_debug('--  CG: No data found in ZX_API_REGISTRATIONS');
      Close c_srvctyp;
      retcode := FND_API.G_RET_STS_ERROR;
      return;
   ELSE
      Close c_srvctyp;
   END IF;


   Open c_api(p_srvc_category,p_api_owner_id);
   LOOP

     print_debug('--  CG: Opening for apis');

     FETCH c_api BULK COLLECT INTO
     t_api.api_owner_id,
     t_api.service_type_id,
     t_api.context_ccid,
     t_api.package_name,
     t_api.procedure_name,
     t_api.service_type_code;

     EXIT WHEN c_api%NOTFOUND;

   END LOOP;

     print_debug('--  CG: before close c_api');
   Close c_api;

   g_counter := 1;

   l_count := 0;

   l_break := FALSE;

/*------------------------------------------------------------------------*/
/*  Generating the individual provider package                            */
/*  to call the service category services for different service types     */
/*------------------------------------------------------------------------*/

   IF t_prv.api_owner_id.LAST < 0 THEN
      print_debug('--  CG: before for loop GCO');
   ELSE
      print_debug('--  CG: before for loop '||to_char(t_prv.api_owner_id.LAST));
   END IF;

   For l_prvidx in 1..nvl(t_prv.api_owner_id.LAST,0) LOOP

      print_debug('--  CG: before l_pack_name ');

      IF t_prv.api_owner_id(l_prvidx) = -99 THEN
         l_api_owner_id_char := 'GCO';
      ELSE
         l_api_owner_id_char := to_char(t_prv.api_owner_id(l_prvidx));
      END IF;
      l_pack_name := 'ZX_THIRD_PARTY_'|| ltrim(rtrim(l_api_owner_id_char)) ||'_PKG';

/*------------------------------------------------------------------------*/
/*   IF all the statuses for the provider are DELETED then drop the       */
/*   package                                                              */
/*------------------------------------------------------------------------*/

      IF (t_prv.status_code(l_prvidx) = 'DELETED') THEN

        ad_ddl.do_ddl(
        'APPS','ZX','AD_DDL.DROP_TABLE','DROP PACKAGE '||l_pack_name,l_pack_name );

      ELSIF (t_prv.status_code(l_prvidx) <> 'GENERATED') THEN

        g_counter := 1;
/*------------------------------------------------------------------------*/
/*   IF distinct statuses are not GENERATED then only generate the        */
/*   individual package specification                                     */
/*------------------------------------------------------------------------*/

     print_debug('--  CG: create_third_party ');
        create_third_party_pkg_spec;
/* ---------------------------------------------------------------------------
  Looping through the record of tables again for generating the individual
  service type procedures
 ----------------------------------------------------------------------------*/

        g_counter := 1;

        l_string :=  'CREATE OR REPLACE PACKAGE BODY '||l_pack_name||' AS';
        print_string(l_string);

     print_debug('--  CG: Before insert_gbl_val_for_debug');
        insert_gbl_var_for_debug(l_pack_name);

        l_break := FALSE;

        FOR l_srvcidx in  1..nvl(t_srvc.api_owner_id.LAST,0) LOOP

           IF (t_srvc.api_owner_id(l_srvcidx) = t_prv.api_owner_id(l_prvidx)) THEN

             l_break := TRUE;

             l_switch_mode := TRUE;

             get_srvc_typ_params ( t_srvc.service_type_id(l_srvcidx),
                                   t_srvc.service_type_code(l_srvcidx),
                                   t_srvc.data_transfer_code(l_srvcidx),
                                   'HEADER',
                                   NULL,
                                   NULL,
                                   r_srvcparamtbl,
                                   l_no_of_strings,
                                   l_return_status);

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               retcode := l_return_status;
               print_debug('Parameter data not seeded for Service type Id '||to_char(t_srvc.service_type_id(l_srvcidx)));
               EXIT;

             END IF;

     print_debug('--  CG: after get_srvctyp_params');
            FOR i in 0..l_no_of_strings LOOP
                l_string := r_srvcparamtbl(i);
                print_string(l_string);
            END LOOP;

            l_string := 'InvalidContextCcid Exception;';
            print_string(l_string);

            l_string := 'l_api_name  CONSTANT VARCHAR2(80) := ''';
            l_string := l_string || t_srvc.service_type_code(l_srvcidx)|| ''';';
            print_string(l_string);

            l_string := ' Begin ';
            print_string(l_string);

            insert_debug('BEGIN', NULL);

            l_first := TRUE;

            FOR l_apiidx in 1..nvl(t_api.api_owner_id.LAST,0) Loop

              IF (t_srvc.api_owner_id(l_srvcidx) = t_api.api_owner_id(l_apiidx) AND
                   t_srvc.service_type_id(l_srvcidx) = t_api.service_type_id(l_apiidx)) THEN

               IF l_first THEN

                  l_string := 'IF p_context_ccid = '||to_char(t_api.context_ccid(l_apiidx))||' THEN ';
                  print_string(l_string);
                  l_first := FALSE;

               ELSE

                 l_string := 'ELSIF p_context_ccid = '||to_char(t_api.context_ccid(l_apiidx))||' THEN ';
                  print_string(l_string);

               END IF;

     print_debug('--  CG: before 2nd get_srvctyp_params');
               get_srvc_typ_params ( t_srvc.service_type_id(l_srvcidx),
                                     t_srvc.service_type_code(l_srvcidx),
                                     t_srvc.data_transfer_code(l_srvcidx),
                                     'PARTNER',
                                     t_api.package_name(l_apiidx),
                                     t_api.procedure_name(l_apiidx),
                                     r_srvcparamtbl,
                                     l_no_of_strings,
                                     l_return_status);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 retcode := l_return_status;
                 print_debug('Parameter data not seeded for Service type Id '||to_char(t_srvc.service_type_id(l_srvcidx)));
                  EXIT;

               END IF;

               FOR i in 0..l_no_of_strings LOOP
                   l_string := r_srvcparamtbl(i);
                   print_string(l_string);
               END LOOP;

              END IF;

            END LOOP;

            l_string := 'ELSE  ';
            print_string(l_string);

            l_string := 'Raise InvalidContextCcid; ';
            print_string(l_string);

            l_string := 'END IF; ';
            print_string(l_string);

            l_string := 'EXCEPTION ';
            print_string(l_string);

            l_string := 'WHEN InvalidContextccid THEN ';
            print_string(l_string);

            l_string := 'ERROR_STATUS := FND_API.G_RET_STS_ERROR;';
            print_string(l_string);

            l_string :=  'FND_MESSAGE.SET_NAME(''ZX'',''ZX_INVALID_CONTEXT_CCID'');';
            print_string(l_string);

            l_string := 'FND_MSG_PUB.ADD;';
            print_string(l_string);

            l_string := 'Return; ';
            print_string(l_string);

            l_string := 'END '||t_srvc.service_type_code(l_srvcidx)||';';
            print_string(l_string);

/* -----------------------------------------------------------------------------*/
/*   Updating the status of all records to GENERATED                            */
/* ----------------------------------------------------------------------------- */


              UPDATE ZX_API_OWNER_STATUSES SET STATUS_CODE = 'GENERATED'
              WHERE api_owner_id = t_prv.api_owner_id(l_prvidx);

           END IF;

           IF ((t_srvc.api_owner_id(l_srvcidx) <> t_prv.api_owner_id(l_prvidx))
                AND l_break ) THEN

             EXIT;

           END IF;

           END LOOP;

     print_debug('--  CG: before create_main_router_body');
          create_main_router_body(l_prvidx);
          l_string := 'END '||l_pack_name||' ;';
          print_string(l_string);
          print_debug('--  CG: Before creating pl/sql object '||l_pack_name || 'G_counter = '|| to_char(g_counter));

          ad_ddl.create_plsql_object(
          'APPS','ZX',l_pack_name,1,(g_counter-1),'TRUE',dummy);

          print_debug('--  CG: After creating pl/sql object');


         END IF;

         END LOOP;

/*------------------------------------------------------------------------*/
/*   Creating the main wrapper package body                               */
/*------------------------------------------------------------------------*/

        IF (nvl(l_exists,'N') = 'Y') THEN

          g_counter := 1;

          l_first := TRUE;

          l_string := 'CREATE OR REPLACE PACKAGE BODY ZX_'||p_srvc_category||'_PKG AS';
          print_string(l_string);

          l_pack_name := 'ZX_' || p_srvc_category || '_PKG';
          insert_gbl_var_for_debug(l_pack_name);

          l_string := 'PROCEDURE INVOKE_THIRD_PARTY_INTERFACE(p_api_owner_id IN Number';
          print_string(l_string);
          l_string := ', p_service_type_id IN Number';
          print_string(l_string);
          l_string := ', p_context_ccid IN Number';
          print_string(l_string);
          l_string := ', p_data_transfer_mode IN VARCHAR2';
          print_string(l_string);
          l_string := ', x_return_status OUT NOCOPY VARCHAR2) IS ';
          print_string(l_string);

          l_string := 'InvalidApiownId Exception; ';
          print_string(l_string);

          l_string := 'l_api_name  CONSTANT VARCHAR2(80) := ''INVOKE_THIRD_PARTY_INTERFACE'';';
          print_string(l_string);

          l_string := 'Begin ';
          print_string(l_string);

          insert_debug('BEGIN', NULL);

          For l_prvidx in 1..t_prv.api_owner_id.LAST LOOP

            IF l_first THEN

              l_string := 'IF p_api_owner_id = '||to_char(t_prv.api_owner_id(l_prvidx))||' THEN ';
              print_string(l_string);

              l_first := FALSE;

           ELSE

              l_string := 'ELSIF p_api_owner_id = '||to_char(t_prv.api_owner_id(l_prvidx))||' THEN ';
              print_string(l_string);

          END IF;

          IF t_prv.api_owner_id(l_prvidx) = -99 THEN
             l_api_owner_id_char := 'GCO';
          ELSE
             l_api_owner_id_char := to_char(t_prv.api_owner_id(l_prvidx));
          END IF;

          l_string := 'ZX_Third_party_' ||
                        rtrim(ltrim(l_api_owner_id_char)) ||
--                        rtrim(ltrim(to_char(t_prv.api_owner_id(l_prvidx)))) ||
                        '_pkg.main_router(p_service_type_id';
            print_string(l_string);
            l_string := ', p_context_ccid';
            print_string(l_string);
            l_string := ', p_data_transfer_mode';
            print_string(l_string);
            l_string := ', x_return_status );';
            print_string(l_string);

            l_string := 'IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN';
            print_string(l_string);

            l_string := ' Return; ';
            print_string(l_string);

            l_string := ' END IF; ';
            print_string(l_string);

          END LOOP;

            l_string := 'ELSE ';
           print_string(l_string);

            l_string := 'Raise InvalidApiownid ; ';
           print_string(l_string);

            l_string := 'END IF; ';
           print_string(l_string);

            l_string := 'END invoke_third_party_interface; ';
           print_string(l_string);

            l_string := 'END ZX_'||p_srvc_category||'_PKG ;';
           print_string(l_string);

            ad_ddl.create_plsql_object(
            'APPS','ZX','ZX_'||p_srvc_category||'_PKG',1,(g_counter-1),'TRUE',dummy);

           END IF;

END generate_code;
END ZX_TPI_PLUGIN_PKG;

/
