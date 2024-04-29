--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_DETAILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_DETAILS_GRP" as
/*$Header: csigttxb.pls 120.3 2007/02/09 22:00:41 jpwilson ship $*/

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_details_grp';
  g_file_name   CONSTANT VARCHAR2(12) := 'csigttxb.pls';

  g_user_id              NUMBER := FND_GLOBAL.user_id;
  g_login_id             NUMBER := FND_GLOBAL.login_id;

  /*
     This procedure checks for the existence of a transaction details
     record in the database . The key to identify the txn line record is
     transaction_source_table, transaction_source_id.
     Returns a 'Y' or 'N'
  */

  FUNCTION check_txn_details_exist(
    p_txn_line_rec  IN  csi_t_datastructures_grp.txn_line_rec)
  RETURN BOOLEAN
  IS

    l_found          boolean := FALSE;
    l_api_name       CONSTANT VARCHAR2(30)  := 'check_txn_details_exist';

  BEGIN

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(true);
    END IF;
    ****/

    l_found := csi_t_txn_details_pvt.check_txn_details_exist(
        p_txn_line_rec  => p_txn_line_rec);

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    csi_t_gen_utility_pvt.set_debug_off;
    return l_found;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      csi_t_gen_utility_pvt.set_debug_off;
      RETURN false;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      csi_t_gen_utility_pvt.set_debug_off;
      RETURN false;

    WHEN OTHERS THEN

      csi_t_gen_utility_pvt.set_debug_off;
      RETURN false;

  END check_txn_details_exist;


  /*
     This procedure gets the transaction details for the given transaction lines.
  */
  PROCEDURE get_transaction_details(
     p_api_version          IN  NUMBER
    ,p_commit               IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_query_rec   IN  csi_t_datastructures_grp.txn_line_query_rec
    ,p_txn_line_detail_query_rec   IN  csi_t_datastructures_grp.txn_line_detail_query_rec
    ,x_txn_line_detail_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,p_get_parties_flag     IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_party_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,p_get_pty_accts_flag   IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_pty_acct_detail_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,p_get_ii_rltns_flag    IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,p_get_org_assgns_flag  IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_org_assgn_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,p_get_ext_attrib_vals_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_ext_attrib_vals_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,p_get_csi_attribs_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_csi_ext_attribs_tbl  OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl
    ,p_get_csi_iea_values_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_csi_iea_values_tbl  OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl
    ,p_get_txn_systems_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_systems_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl
    ,x_return_status        OUT NOCOPY VARCHAR2
    ,x_msg_count            OUT NOCOPY NUMBER
    ,x_msg_data             OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'get_transaction_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

---Added (Start) for m-to-m enhancements
    l_get_ii_rltns_flag   VARCHAR2(10);
    l_indx                         PLS_INTEGER ;
    i                               PLS_INTEGER ;
    l_txn_line_query_rec     csi_t_datastructures_grp.txn_line_query_rec ;
    l_loop_cnt                   NUMBER ;
    x_tmp_line_detail_tbl    csi_t_datastructures_grp.txn_line_detail_tbl ;
    x_tmp_party_detail_tbl   csi_t_datastructures_grp.txn_party_detail_tbl ;
    x_tmp_pty_acct_detail_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl ;
    x_tmp_ii_rltns_tbl       csi_t_datastructures_grp.txn_ii_rltns_tbl ;
    x_tmp_org_assgn_tbl      csi_t_datastructures_grp.txn_org_assgn_tbl ;
    x_tmp_ext_attrib_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl ;
    x_tmp_ext_attribs_tbl    csi_t_datastructures_grp.csi_ext_attribs_tbl ;
    x_tmp_iea_values_tbl     csi_t_datastructures_grp.csi_ext_attrib_vals_tbl ;
    x_tmp_systems_tbl        csi_t_datastructures_grp.txn_systems_tbl ;
    l_relation_exists        BOOLEAN ;

  CURSOR txn_line_cur (c_header_id IN NUMBER, c_line_id IN NUMBER)
  IS
  SELECT a.transaction_line_id,
         a.source_transaction_id
  FROM   csi_t_transaction_lines a
  WHERE  a.source_txn_header_id = c_header_id
  AND    a.transaction_line_id = DECODE(c_line_id,fnd_api.g_miss_num, a.transaction_line_id,NULL, a.transaction_line_id, c_line_id);

---Added (End) for m-to-m enhancements

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT get_transaction_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Get Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception

    csi_utility_grp.check_ib_active;

    -- Added for CZ Integration (Begin)
    l_txn_line_query_rec := p_txn_line_query_rec ;
    IF  NVL(l_txn_line_query_rec.config_session_hdr_id , fnd_api.g_miss_num)
        <> fnd_api.g_miss_num
    THEN
       csi_t_gen_utility_pvt.add ('getting txn line id for session keys');
       ---Get the line id associated with the given Config attribs.
       csi_t_vldn_routines_pvt.get_cz_txn_line_id(
       p_config_session_hdr_id => p_txn_line_query_rec.config_session_hdr_id,
       p_config_session_rev_num => p_txn_line_query_rec.config_session_rev_num,
       p_config_session_item_id => p_txn_line_query_rec.config_session_item_id ,
       x_txn_line_id => l_txn_line_query_rec.transaction_line_id,
       x_return_status => x_return_status);

       IF x_return_status <> fnd_api.g_ret_sts_success
       THEN
          RAISE FND_API.g_exc_error;
       END IF ;

    END IF ;
    -- Added for CZ Integration (End)

    ---Added (Start) for m-to-m enhancements
    l_loop_cnt := 0;
    IF l_txn_line_query_rec.source_txn_header_id IS NOT NULL
    AND l_txn_line_query_rec.source_txn_header_id <> fnd_api.g_miss_num
    THEN
       --IF l_txn_line_query_rec.source_transaction_type_id = 51
       --THEN
          FOR txn_line_rec IN txn_line_cur (l_txn_line_query_rec.source_txn_header_id, l_txn_line_query_rec.transaction_line_id)
          LOOP
             ---This is to make sure that we get relationships for the header
             ---only once

             l_loop_cnt := l_loop_cnt+1 ;

             IF l_txn_line_query_rec.transaction_line_id IS NULL
                OR l_txn_line_query_rec.transaction_line_id=fnd_api.g_miss_num
             THEN
                l_txn_line_query_rec.transaction_line_id := txn_line_rec.transaction_line_id ;
             END IF ;

             csi_t_txn_details_pvt.get_transaction_details(
               p_api_version              => p_api_version,
               p_commit                   => p_commit,
               p_init_msg_list            => p_init_msg_list,
               p_validation_level         => p_validation_level,
               p_txn_line_query_rec       => l_txn_line_query_rec,
               p_txn_line_detail_query_rec => p_txn_line_detail_query_rec,
               x_txn_line_detail_tbl      => x_tmp_line_detail_tbl,
               p_get_parties_flag         => p_get_parties_flag,
               x_txn_party_detail_tbl     => x_tmp_party_detail_tbl,
               p_get_pty_accts_flag       => p_get_pty_accts_flag,
               x_txn_pty_acct_detail_tbl  => x_tmp_pty_acct_detail_tbl,
               p_get_ii_rltns_flag        => l_get_ii_rltns_flag,
               x_txn_ii_rltns_tbl         => x_tmp_ii_rltns_tbl,
               p_get_org_assgns_flag      => p_get_org_assgns_flag,
               x_txn_org_assgn_tbl        => x_tmp_org_assgn_tbl,
               p_get_ext_attrib_vals_flag => p_get_ext_attrib_vals_flag,
               x_txn_ext_attrib_vals_tbl  => x_tmp_ext_attrib_vals_tbl,
               p_get_csi_attribs_flag     => p_get_csi_attribs_flag,
               x_csi_ext_attribs_tbl      => x_tmp_ext_attribs_tbl,
               p_get_csi_iea_values_flag  => p_get_csi_iea_values_flag,
               x_csi_iea_values_tbl       => x_tmp_iea_values_tbl,
               p_get_txn_systems_flag     => p_get_txn_systems_flag,
               x_txn_systems_tbl          => x_tmp_systems_tbl,
               x_return_status            => l_return_status,
               x_msg_count                => l_msg_count,
               x_msg_data                 => l_msg_data);

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
             END IF;

             IF x_tmp_line_detail_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_txn_line_detail_tbl.LAST,0)+1  ;
                FOR i IN x_tmp_line_detail_tbl.FIRST .. x_tmp_line_detail_tbl.LAST
                LOOP
                   x_txn_line_detail_tbl(l_indx) := x_tmp_line_detail_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_line_detail_tbl.FIRST

             END IF ; ---x_tmp_line_detail_tbl.COUNT > 0

             IF x_tmp_party_detail_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_txn_party_detail_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_party_detail_tbl.FIRST .. x_tmp_party_detail_tbl.LAST
                LOOP
                   x_txn_party_detail_tbl(l_indx) := x_tmp_party_detail_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_party_detail_tbl.FIRST

             END IF ; ---x_tmp_party_detail_tbl.COUNT > 0

             IF x_tmp_pty_acct_detail_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_txn_pty_acct_detail_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_pty_acct_detail_tbl.FIRST .. x_tmp_pty_acct_detail_tbl.LAST
                LOOP
                   x_txn_pty_acct_detail_tbl(l_indx) := x_tmp_pty_acct_detail_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_pty_acct_detail_tbl.FIRST

             END IF ; ---x_tmp_pty_acct_detail_tbl.COUNT > 0

             IF x_tmp_ii_rltns_tbl.COUNT > 0
             THEN
                FOR i IN x_tmp_ii_rltns_tbl.FIRST .. x_tmp_ii_rltns_tbl.LAST
                LOOP
                  l_relation_exists := FALSE ;
                  -- bug 2795136 added the if condition
                  IF x_txn_ii_rltns_tbl.COUNT > 0 THEN
                    FOR j IN x_txn_ii_rltns_tbl.FIRST .. x_txn_ii_rltns_tbl.LAST
                    LOOP
                       IF x_txn_ii_rltns_tbl(j).txn_relationship_id
                           = x_tmp_ii_rltns_tbl(i).txn_relationship_id
                       THEN
                          --relationship already exists
                          l_relation_exists := TRUE ;
                          EXIT ;
                       END IF ;
                    END LOOP ; --x_txn_ii_rltns_tbl.FIRST
                  END IF;
                  IF NOT l_relation_exists
                  THEN
                    l_indx := NVL(x_txn_ii_rltns_tbl.LAST,0)+1 ;
                    x_txn_ii_rltns_tbl(l_indx) := x_tmp_ii_rltns_tbl(i) ;
                  END IF ;
                END LOOP ; ---x_tmp_ii_rltns_tbl.FIRST

             END IF ; ---x_tmp_ii_rltns_tbl.COUNT > 0

             IF x_tmp_org_assgn_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_txn_org_assgn_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_org_assgn_tbl.FIRST .. x_tmp_org_assgn_tbl.LAST
                LOOP
                   x_txn_org_assgn_tbl(l_indx) := x_tmp_org_assgn_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_org_assgn_tbl.FIRST

             END IF ; ---x_tmp_org_assgn_tbl.COUNT > 0

             IF x_tmp_ext_attrib_vals_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_txn_ext_attrib_vals_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_ext_attrib_vals_tbl.FIRST .. x_tmp_ext_attrib_vals_tbl.LAST
                LOOP
                   x_txn_ext_attrib_vals_tbl(l_indx) := x_tmp_ext_attrib_vals_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_ext_attrib_vals_tbl.FIRST

             END IF ; ---x_tmp_ext_attrib_vals_tbl.COUNT > 0

             IF x_tmp_ext_attribs_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_csi_ext_attribs_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_ext_attribs_tbl.FIRST .. x_tmp_ext_attribs_tbl.LAST
                LOOP
                   x_csi_ext_attribs_tbl(l_indx) := x_tmp_ext_attribs_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_ext_attribs_tbl.FIRST

             END IF ; ---x_tmp_ext_attribs_tbl.COUNT > 0

             IF x_tmp_iea_values_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_csi_iea_values_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_iea_values_tbl.FIRST .. x_tmp_iea_values_tbl.LAST
                LOOP
                   x_csi_iea_values_tbl(l_indx) := x_tmp_iea_values_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_iea_values_tbl.FIRST

             END IF ; ---x_tmp_iea_values_tbl.COUNT > 0

             IF x_tmp_systems_tbl.COUNT > 0
             THEN
                l_indx := NVL(x_txn_systems_tbl.LAST,0)+1 ;
                FOR i IN x_tmp_systems_tbl.FIRST .. x_tmp_systems_tbl.LAST
                LOOP
                   x_txn_systems_tbl(l_indx) := x_tmp_systems_tbl(i) ;
                   l_indx := l_indx + 1 ;
                END LOOP ; ---x_tmp_systems_tbl.FIRST

             END IF ; ---x_tmp_systems_tbl.COUNT > 0

           END LOOP ; ---txn_line_cur

           -- Standard check of p_commit.
           IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
           END IF;

           /**** Commented for Bug 3304439
           -- Check for the profile option and disable the trace
           IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y')
           THEN
             dbms_session.set_sql_trace(false);
           END IF;
           ****/

           -- Standard call to get message count and if count is  get message info.
           FND_MSG_PUB.Count_And_Get(
             p_count  =>  x_msg_count,
             p_data   =>  x_msg_data);

       --END IF ;  ---p_txn_line_query_rec.source_transaction_type_id=51
    ELSE
    ---Added (End) for m-to-m enhancements

       csi_t_txn_details_pvt.get_transaction_details(
            p_api_version              => p_api_version,
            p_commit                   => p_commit,
            p_init_msg_list            => p_init_msg_list,
            p_validation_level         => p_validation_level,
            p_txn_line_query_rec       => l_txn_line_query_rec,
            p_txn_line_detail_query_rec => p_txn_line_detail_query_rec,
            x_txn_line_detail_tbl      => x_txn_line_detail_tbl,
            p_get_parties_flag         => p_get_parties_flag,
            x_txn_party_detail_tbl     => x_txn_party_detail_tbl,
            p_get_pty_accts_flag       => p_get_pty_accts_flag,
            x_txn_pty_acct_detail_tbl  => x_txn_pty_acct_detail_tbl,
            p_get_ii_rltns_flag        => p_get_ii_rltns_flag,
            x_txn_ii_rltns_tbl         => x_txn_ii_rltns_tbl,
            p_get_org_assgns_flag      => p_get_org_assgns_flag,
            x_txn_org_assgn_tbl        => x_txn_org_assgn_tbl,
            p_get_ext_attrib_vals_flag => p_get_ext_attrib_vals_flag,
            x_txn_ext_attrib_vals_tbl  => x_txn_ext_attrib_vals_tbl,
            p_get_csi_attribs_flag     => p_get_csi_attribs_flag,
            x_csi_ext_attribs_tbl      => x_csi_ext_attribs_tbl,
            p_get_csi_iea_values_flag  => p_get_csi_iea_values_flag,
            x_csi_iea_values_tbl       => x_csi_iea_values_tbl,
            p_get_txn_systems_flag     => p_get_txn_systems_flag,
            x_txn_systems_tbl          => x_txn_systems_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
        END IF;

        /**** Commented for Bug 3304439
        -- Check for the profile option and disable the trace
        IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
          dbms_session.set_sql_trace(false);
        END IF;
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get(
          p_count  =>  x_msg_count,
          p_data   =>  x_msg_data);
    END IF ; --p_txn_line_query_rec.source_txn_header_id is NOT NULL

    csi_t_gen_utility_pvt.add('API Executed         : Get Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Get_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Get_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Get_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END get_transaction_details;
  /*
     This procedure creates new transaction line details, party associations,
     configuration details, org assignments and extended attributes for
     a transaction line
  */
  PROCEDURE create_transaction_dtls
  (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,px_txn_line_rec         IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec
    ,px_txn_line_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_party_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_ii_rltns_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_org_assgn_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,px_txn_systems_tbl      IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
  )
  IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'create_transaction_dtls';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_debug_level                  NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

    l_count                        NUMBER;

    l_txn_line_id                  NUMBER;
    l_txn_line_rec                 csi_t_datastructures_grp.txn_line_rec;
    l_line_dtl_rec                 csi_t_datastructures_grp.txn_line_detail_rec;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_transaction_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Create Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- main code starts here
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    -- Added for CZ Integration  (Begin)
    IF NVL(px_txn_line_rec.config_session_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num
    AND px_txn_line_rec.api_caller_identity <> 'CONFIG'
    THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
      FND_MESSAGE.set_token('API_CALLER',px_txn_line_rec.api_caller_identity) ;
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF ;

    IF NVL(px_txn_line_rec.source_transaction_type_id , -1) = 401
    AND NVL(px_txn_line_rec.config_session_hdr_id , fnd_api.g_miss_num)
          = fnd_api.g_miss_num
    THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_CZ_KEYS_NOT_GIVEN');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF ;

    IF NVL(px_txn_line_rec.source_transaction_type_id , -1) <> 401
    AND NVL(px_txn_line_rec.config_session_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num
    THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_SOURCE');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF ;
    -- Added for CZ Integration  (End)


    -- 07-12 Changed as a bug fix
    -- Initilize the txn_line_detail_id with PL/SQL index
    -- Assumption is the pl/sql indexes start with 1 and are
    -- continuous.
    IF px_txn_line_detail_tbl.count > 0 THEN
       FOR i IN px_txn_line_detail_tbl.FIRST .. px_txn_line_detail_tbl.LAST
       LOOP
          px_txn_line_detail_tbl(i).txn_line_detail_id := i ;
       END LOOP ;
    END IF;

    csi_t_txn_details_pvt.create_transaction_dtls(
      p_api_version           => p_api_version,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => p_init_msg_list,
      p_validation_level      => p_validation_level,
      px_txn_line_rec         => px_txn_line_rec,
      px_txn_line_detail_tbl  => px_txn_line_detail_tbl,
      px_txn_party_detail_tbl => px_txn_party_detail_tbl,
      px_txn_pty_acct_detail_tbl  => px_txn_pty_acct_detail_tbl,
      px_txn_ii_rltns_tbl     => px_txn_ii_rltns_tbl,
      px_txn_org_assgn_tbl    => px_txn_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl  => px_txn_ext_attrib_vals_tbl,
      px_txn_systems_tbl      => px_txn_systems_tbl,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Executed         : Create Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO create_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO create_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

  END create_transaction_dtls;

  /*
     This procedure is used to update the transaction line details.
  */
  PROCEDURE update_txn_line_dtls(
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_rec           IN  csi_t_datastructures_grp.txn_line_rec
    ,p_txn_line_detail_tbl    IN  csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_ii_rltns_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_org_assgn_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  )

  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_txn_line_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_line_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Update Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    -- Added for CZ Integration  (Begin)
    IF NVL(p_txn_line_rec.config_session_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num
    AND p_txn_line_rec.api_caller_identity <> 'CONFIG'
    THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
      FND_MESSAGE.set_token('API_CALLER',p_txn_line_rec.api_caller_identity);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF ;
    -- Added for CZ Integration  (End)

    csi_t_txn_line_dtls_pvt.update_txn_line_dtls(
      p_api_version              => p_api_version,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => p_init_msg_list,
      p_validation_level         => p_validation_level,
      p_txn_line_rec             => p_txn_line_rec,
      p_txn_line_detail_tbl      => p_txn_line_detail_tbl,
      px_txn_ii_rltns_tbl        => px_txn_ii_rltns_tbl,
      px_txn_party_detail_tbl    => px_txn_party_detail_tbl,
      px_txn_pty_acct_detail_tbl => px_txn_pty_acct_detail_tbl,
      px_txn_org_assgn_tbl       => px_txn_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl => px_txn_ext_attrib_vals_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.dump_error_stack;

    csi_t_gen_utility_pvt.add('API Executed         : Update Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_Txn_Line_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Txn_Line_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Update_Txn_Line_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

  END update_txn_line_dtls;

  /*
  */
  PROCEDURE delete_transaction_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_transaction_line_id    IN  NUMBER
    ,p_api_caller_identity    IN  VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'Delete_Transaction_Dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_config_session_hdr_id   NUMBER ;
    l_validation_level        NUMBER := NULL;

CURSOR txn_line_cur
IS
SELECT config_session_hdr_id
FROM   csi_t_transaction_lines
WHERE  transaction_line_id = p_transaction_line_id ;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Delete_Transaction_Dtls;


    csi_t_gen_utility_pvt.add('API Being Executed     : Delete Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --
    csi_utility_grp.check_ib_active;
    IF p_api_caller_identity <> 'CONFIG'
    THEN
       ---check whether txn_line_id has config parameters set
       OPEN txn_line_cur ;
       FETCH txn_line_cur INTO l_config_session_hdr_id;
       CLOSE txn_line_cur ;
       IF l_config_session_hdr_id IS NOT NULL
       THEN
          FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
          FND_MESSAGE.set_token('API_CALLER',p_api_caller_identity);
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
       END IF ;
    END IF ;

    -- Needed to pass some parameter to identify that this is being called from the PURGE program
    IF p_api_caller_identity = 'PURGE' THEN
      l_validation_level := 999;
    ELSE
      l_validation_level := NULL;
    END IF;

    csi_t_txn_details_pvt.delete_transaction_dtls(
      p_api_version         => p_api_version,
      p_commit              => p_commit,
      p_init_msg_list       => p_init_msg_list,
      p_validation_level    => l_validation_level,
      p_transaction_line_id => p_transaction_line_id,
      p_txn_line_detail_id  => null,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/


    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);


    csi_t_gen_utility_pvt.add('API Executed         : Delete Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Delete_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Delete_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

  END delete_transaction_dtls;


  PROCEDURE copy_transaction_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    p_src_txn_line_rec      IN  csi_t_datastructures_grp.txn_line_rec,
    px_new_txn_line_rec     IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_copy_parties_flag     IN  varchar2 := fnd_api.g_true,
    p_copy_pty_accts_flag   IN  varchar2 := fnd_api.g_true,
    p_copy_ii_rltns_flag    IN  varchar2 := fnd_api.g_true,
    p_copy_org_assgn_flag   IN  varchar2 := fnd_api.g_true,
    p_copy_ext_attribs_flag IN  varchar2 := fnd_api.g_true,
    p_copy_txn_systems_flag IN  varchar2 := fnd_api.g_true,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'copy_transaction_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT copy_transaction_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Copy Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;
    ****/

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_txn_details_pvt.copy_transaction_dtls(
      p_api_version           => p_api_version,
      p_commit                => p_commit,
      p_init_msg_list         => p_init_msg_list,
      p_validation_level      => p_validation_level,
      p_src_txn_line_rec      => p_src_txn_line_rec,
      px_new_txn_line_rec     => px_new_txn_line_rec,
      p_copy_parties_flag     => p_copy_parties_flag,
      p_copy_pty_accts_flag   => p_copy_pty_accts_flag,
      p_copy_ii_rltns_flag    => p_copy_ii_rltns_flag,
      p_copy_org_assgn_flag   => p_copy_org_assgn_flag,
      p_copy_ext_attribs_flag => p_copy_ext_attribs_flag,
      p_copy_txn_systems_flag => p_copy_txn_systems_flag,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    /**** Commented for Bug 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);


    csi_t_gen_utility_pvt.add('API Executed         : Copy Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO copy_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO copy_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO copy_Transaction_Dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

  END copy_transaction_dtls;


  /*
     This API is for managing the transaction details entities incl. the line details.
  */
  PROCEDURE update_transaction_dtls(
     p_api_version              IN  NUMBER
    ,p_commit                   IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list            IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level         IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_rec             IN  csi_t_datastructures_grp.txn_line_rec
    ,px_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_transaction_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(512);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_transaction_dtls;

    csi_t_gen_utility_pvt.add('API Being Executed     : Update Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    IF l_debug_level > 1 THEN
      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => p_txn_line_rec);
    END IF;

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_rec.transaction_line_id,
      p_param_name  => 'p_txn_line_rec.transaction_line_id',
      p_api_name    => l_api_name);


    -- Calling the Private ...
    csi_t_txn_details_pvt.update_transaction_dtls(
      p_api_version              => p_api_version,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => p_init_msg_list,
      p_validation_level         => p_validation_level,
      p_txn_line_rec             => p_txn_line_rec,
      px_txn_line_detail_tbl     => px_txn_line_detail_tbl,
      px_txn_ii_rltns_tbl        => px_txn_ii_rltns_tbl,
      px_txn_party_detail_tbl    => px_txn_party_detail_tbl,
      px_txn_pty_acct_detail_tbl => px_txn_pty_acct_detail_tbl,
      px_txn_org_assgn_tbl       => px_txn_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl => px_txn_ext_attrib_vals_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.dump_error_stack;

    csi_t_gen_utility_pvt.add('API Executed         : Update Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO update_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO update_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO update_transaction_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.dump_error_stack;
      csi_t_gen_utility_pvt.set_debug_off;

  END update_transaction_dtls;

   PROCEDURE split_transaction_details(
    p_api_version             IN  NUMBER,
    p_commit                  IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full,
    p_src_txn_line_rec        IN  csi_t_datastructures_grp.txn_line_rec,
    px_split_txn_line_rec     IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_line_dtl_tbl           IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_pty_dtl_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_pty_acct_tbl            OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_org_assgn_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_txn_ext_attrib_vals_tbl OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_txn_systems_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'split_transaction_details';
    l_api_version    CONSTANT NUMBER        := 1.0;

  BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT split_transaction_details;

    csi_t_gen_utility_pvt.add('API Being Executed     : Split Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT
       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Check for the profile option and enable trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(TRUE);
    END IF;

    -- Main API code
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    csi_t_txn_details_pvt.split_transaction_details
    (
       p_api_version           => p_api_version,
       p_commit                => p_commit,
       p_init_msg_list         => p_init_msg_list,
       p_validation_level      => p_validation_level,
       p_src_txn_line_rec      => p_src_txn_line_rec,
       px_split_txn_line_rec   => px_split_txn_line_rec,
       px_line_dtl_tbl         => px_line_dtl_tbl,
       x_pty_dtl_tbl           => x_pty_dtl_tbl,
       x_pty_acct_tbl          => x_pty_acct_tbl,
       x_org_assgn_tbl         => x_org_assgn_tbl,
       x_txn_ext_attrib_vals_tbl => x_txn_ext_attrib_vals_tbl,
       x_txn_systems_tbl       => x_txn_systems_tbl,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data
    );
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
      dbms_session.set_sql_trace(false);
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

    csi_t_gen_utility_pvt.add('API Executed         : Copy Transaction Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO split_transaction_details;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO split_transaction_details;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO split_transaction_details;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

  END split_transaction_details;

END csi_t_txn_details_grp;

/
