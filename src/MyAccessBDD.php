<?php

include_once("AccessBDD.php");

/**
 * Classe de construction des requêtes SQL
 * hérite de AccessBDD qui contient les requêtes de base
 * Pour ajouter une requête :
 * - créer la fonction qui crée une requête (prendre modèle sur les fonctions 
 *   existantes qui ne commencent pas par 'traitement')
 * - ajouter un 'case' dans un des switch des fonctions redéfinies 
 * - appeler la nouvelle fonction dans ce 'case'
 */
class MyAccessBDD extends AccessBDD {

    /**
     * constructeur qui appelle celui de la classe mère
     */
    public function __construct() {
        try {
            parent::__construct();
        } catch (\Exception $e) {
            throw $e;
        }
    }

    /**
     * demande de recherche
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return array|null tuples du résultat de la requête ou null si erreur
     * @override
     */
    protected function traitementSelect(string $table, ?array $champs): ?array {
        switch ($table) {
            case "livre" :
                return $this->selectAllLivres();
            case "dvd" :
                return $this->selectAllDvd();
            case "revue" :
                return $this->selectAllRevues();
            case "exemplaire" :
                return $this->selectExemplairesRevue($champs);
            case "genre" :
            case "public" :
            case "rayon" :
            case "etat" :
            case "suivi" :
                // select portant sur une table contenant juste id et libelle
                return $this->selectTableSimple($table);
            case "commandedocument" :
                return $this->selectCommandesLivreDvd($champs);
            case "commandes" :
                return $this->selectAllCommandes();
            case "abonnement" :
                return $this->selectAbonnementsRevue($champs);
            case "expiration" :
                return $this->selectRevueExpirationMois();
            default:
                // cas général
                return $this->selectTuplesOneTable($table, $champs);
        }
    }

    /**
     * demande d'ajout (insert)
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples ajoutés ou null si erreur
     * @override
     */
    protected function traitementInsert(string $table, ?array $champs): ?int {
        switch ($table) {
            case "commandedocument" :
                return $this->insertCommandeDocument($champs);
            case "abonnement" :
                return $this->insertAbonnement($champs);
            default:
                // cas général
                return $this->insertOneTupleOneTable($table, $champs);
        }
    }

    /**
     * demande de modification (update)
     * @param string $table
     * @param string|null $id
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples modifiés ou null si erreur
     * @override
     */
    protected function traitementUpdate(string $table, ?string $id, ?array $champs): ?int {
        switch ($table) {
            case "commandedocument" :
                return $this->updateCommandeDocument($champs);
            default:
                // cas général
                return $this->updateOneTupleOneTable($table, $id, $champs);
        }
    }

    /**
     * demande de suppression (delete)
     * @param string $table
     * @param array|null $champs nom et valeur de chaque champ
     * @return int|null nombre de tuples supprimés ou null si erreur
     * @override
     */
    protected function traitementDelete(string $table, ?array $champs): ?int {
        switch ($table) {
            case "" :
            // return $this->uneFonction(parametres);
            default:
                // cas général
                return $this->deleteTuplesOneTable($table, $champs);
        }
    }

    /**
     * récupère les tuples d'une seule table
     * @param string $table
     * @param array|null $champs
     * @return array|null 
     */
    private function selectTuplesOneTable(string $table, ?array $champs): ?array {
        if (empty($champs)) {
            // tous les tuples d'une table
            $requete = "select * from $table;";
            return $this->conn->queryBDD($requete);
        } else {
            // tuples spécifiques d'une table
            $requete = "select * from $table where ";
            foreach ($champs as $key => $value) {
                $requete .= "$key=:$key and ";
            }
            // (enlève le dernier and)
            $requete = substr($requete, 0, strlen($requete) - 5);
            return $this->conn->queryBDD($requete, $champs);
        }
    }

    /**
     * demande d'ajout (insert) d'un tuple dans une table
     * @param string $table
     * @param array|null $champs
     * @return int|null nombre de tuples ajoutés (0 ou 1) ou null si erreur
     */
    private function insertOneTupleOneTable(string $table, ?array $champs): ?int {
        if (empty($champs)) {
            return null;
        }
        // construction de la requête
        $requete = "insert into $table (";
        foreach ($champs as $key => $value) {
            $requete .= "$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete) - 1);
        $requete .= ") values (";
        foreach ($champs as $key => $value) {
            $requete .= ":$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete) - 1);
        $requete .= ");";
        return $this->conn->updateBDD($requete, $champs);
    }

    /**
     * demande de modification (update) d'un tuple dans une table
     * @param string $table
     * @param string\null $id
     * @param array|null $champs 
     * @return int|null nombre de tuples modifiés (0 ou 1) ou null si erreur
     */
    private function updateOneTupleOneTable(string $table, ?string $id, ?array $champs): ?int {
        if (empty($champs)) {
            return null;
        }
        if (is_null($id)) {
            return null;
        }
        // construction de la requête
        $requete = "update $table set ";
        foreach ($champs as $key => $value) {
            $requete .= "$key=:$key,";
        }
        // (enlève la dernière virgule)
        $requete = substr($requete, 0, strlen($requete) - 1);
        $champs["id"] = $id;
        $requete .= " where id=:id;";
        return $this->conn->updateBDD($requete, $champs);
    }

    /**
     * demande de suppression (delete) d'un ou plusieurs tuples dans une table
     * @param string $table
     * @param array|null $champs
     * @return int|null nombre de tuples supprimés ou null si erreur
     */
    private function deleteTuplesOneTable(string $table, ?array $champs): ?int {
        if (empty($champs)) {
            return null;
        }
        // construction de la requête
        $requete = "delete from $table where ";
        foreach ($champs as $key => $value) {
            $requete .= "$key=:$key and ";
        }
        // (enlève le dernier and)
        $requete = substr($requete, 0, strlen($requete) - 5);
        return $this->conn->updateBDD($requete, $champs);
    }

    /**
     * récupère toutes les lignes d'une table simple (qui contient juste id et libelle)
     * @param string $table
     * @return array|null
     */
    private function selectTableSimple(string $table): ?array {
        $requete = "select * from $table order by libelle;";
        return $this->conn->queryBDD($requete);
    }

    /**
     * récupère toutes les lignes de la table Livre et les tables associées
     * @return array|null
     */
    private function selectAllLivres(): ?array {
        $requete = "Select l.id, l.ISBN, l.auteur, d.titre, d.image, l.collection, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from livre l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";
        return $this->conn->queryBDD($requete);
    }

    /**
     * récupère toutes les lignes de la table DVD et les tables associées
     * @return array|null
     */
    private function selectAllDvd(): ?array {
        $requete = "Select l.id, l.duree, l.realisateur, d.titre, d.image, l.synopsis, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from dvd l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";
        return $this->conn->queryBDD($requete);
    }

    /**
     * récupère toutes les lignes de la table Revue et les tables associées
     * @return array|null
     */
    private function selectAllRevues(): ?array {
        $requete = "Select l.id, l.periodicite, d.titre, d.image, l.delaiMiseADispo, ";
        $requete .= "d.idrayon, d.idpublic, d.idgenre, g.libelle as genre, p.libelle as lePublic, r.libelle as rayon ";
        $requete .= "from revue l join document d on l.id=d.id ";
        $requete .= "join genre g on g.id=d.idGenre ";
        $requete .= "join public p on p.id=d.idPublic ";
        $requete .= "join rayon r on r.id=d.idRayon ";
        $requete .= "order by titre ";
        return $this->conn->queryBDD($requete);
    }

    /**
     * récupère tous les exemplaires d'une revue
     * @param array|null $champs 
     * @return array|null
     */
    private function selectExemplairesRevue(?array $champs): ?array {
        if (empty($champs)) {
            return null;
        }
        if (!array_key_exists('id', $champs)) {
            return null;
        }
        $champNecessaire['id'] = $champs['id'];
        $requete = "Select e.id, e.numero, e.dateAchat, e.photo, e.idEtat ";
        $requete .= "from exemplaire e join document d on e.id=d.id ";
        $requete .= "where e.id = :id ";
        $requete .= "order by e.dateAchat DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }

    /**
     * Récupère toutes les commandes relatives à un livre ou un dvd
     * @param array|null $champs : l'id du livre ou du dvd à récupérer
     * @return array|null
     */
    private function selectCommandesLivreDvd(?array $champs): ?array {
        if (empty($champs)) {
            return null;
        }
        if (!array_key_exists('id', $champs)) {
            return null;
        }
        $champNecessaire['idLivreDvd'] = $champs['id'];
        $requete = "Select cd.id, cd.nbExemplaire, cd.idLivreDvd, cd.idSuivi, c.dateCommande, c.montant, s.libelle as suivi ";
        $requete .= "from commandedocument cd join commande c on cd.id = c.id ";
        $requete .= "join suivi s on s.id = cd.idSuivi ";
        $requete .= "where cd.idLivreDvd = :idLivreDvd ";
        $requete .= "order by c.dateCommande DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }

    /**
     * demande d'ajout d'un livre ou d'un dvd dans une table
     * @param array|null $champs
     * @return int|null
     */
    private function insertCommandeDocument(?array $champs): ?int {
        if (empty($champs)) {
            return null;
        }
        $champsNecessaires = ['Id', 'DateCommande', 'Montant', 'NbExemplaire', 'IdLivreDvd', 'IdSuivi'];
        foreach ($champsNecessaires as $champ) {
            if (!array_key_exists($champ, $champs)) {
                return null;
            }
        }
        $champsAUtiliser = [
            'id' => $champs['Id'],
            'dateCommande' => $champs['DateCommande'],
            'montant' => $champs['Montant'],
            'nbExemplaire' => $champs['NbExemplaire'],
            'idLivreDvd' => $champs['IdLivreDvd'],
            'idSuivi' => $champs['IdSuivi']
        ];
        $requete = "CALL InsertCommandeDocument(:id, :dateCommande, :montant, :nbExemplaire, :idLivreDvd, :idSuivi, @success)";
        $success = $this->conn->updateBDD($requete, $champsAUtiliser);
        if ($success === null) {
            return null;
        }
        $result = $this->conn->queryBDD("SELECT @success as success");
        return ($result && isset($result[0]['success']) && $result[0]['success'] == 1) ? 1 : null;
    }

    /**
     * Selectionne toutes les commandes (livredvd + abonnement)
     * @return array|null
     */
    private function selectAllCommandes(): ?array {
        $requete = "Select * from commande;";
        return $this->conn->queryBDD($requete);
    }
    
    /**
     * Modifie les tuples de la table commande et de la table commandedocument qui ont le même id
     * @param array|null $champs
     * @return int|null
     */
    private function updateCommandeDocument(?array $champs) : ?int {
        if (empty($champs)) {
            return null;
        }

        $champsNecessaires = ['Id', 'DateCommande', 'Montant', 'NbExemplaire', 'IdSuivi'];
        foreach ($champsNecessaires as $champ) {
            if (!array_key_exists($champ, $champs)) {
                return null;
            }
        }
        $champsAUtiliser = [
            'id' => $champs['Id'],
            'dateCommande' => $champs['DateCommande'],
            'nbExemplaire' => $champs['NbExemplaire'],
            'montant' => $champs['Montant'],
            'idSuivi' => $champs['IdSuivi']
        ];

        $requete = "CALL updateCommandeDocument(:id, :dateCommande, :nbExemplaire, :montant, :idSuivi)";
        return $this->conn->updateBDD($requete, $champsAUtiliser);
    }
    
    /**
     * Sélectionne tous les abonnements de la revue dont l'id est passée en paramètre
     * @param array|null $champs
     * @return array|null
     */
    private function selectAbonnementsRevue(?array $champs) : ?array {
        if(empty($champs)) {
            return null;
        }
        if (!array_key_exists('id', $champs)) {
            return null;
        }
        $champNecessaire['idRevue'] = $champs['id'];
        $requete = "SELECT c.id, c.dateCommande, c.montant, a.dateFinAbonnement, a.idRevue ";
        $requete .= "FROM commande c JOIN abonnement a ";
        $requete .= "ON c.id = a.id ";
        $requete .= "WHERE a.idRevue = :idRevue ";
        $requete .= "ORDER BY c.dateCommande DESC";
        return $this->conn->queryBDD($requete, $champNecessaire);
    }
    
    /**
     * Insertion d'une commande de revue dans les tables commande et abonnement
     * @param array|null $champs
     * @return int|null
     */
    private function insertAbonnement(?array $champs): ?int {
        if (empty($champs)){
            return null;
        }
        
        $champsNecessaires = ['Id', 'DateCommande', 'Montant', 'DateFinAbonnement', 'IdRevue'];
        foreach ($champsNecessaires as $champ) {
            if (!array_key_exists($champ, $champs)) {
                return null;
            }
        }
        
        $champsAUtiliser = [
            'id' => $champs['Id'],
            'dateCommande' => $champs['DateCommande'],
            'montant' => $champs['Montant'],
            'dateFinAbonnement' => $champs['DateFinAbonnement'],
            'idRevue' => $champs['IdRevue']
        ];
        $requete = "CALL insertAbonnement(:id, :dateCommande, :montant, :dateFinAbonnement, :idRevue)";
        return $this->conn->updateBDD($requete, $champsAUtiliser);
    }
    
    /**
     * Retourne la liste des revues dont les abonnements seront expirés dans 30 jours
     * @return array|null
     */
    private function selectRevueExpirationMois(): ?array
    {
        $requete = "SELECT titre, abonnement.dateFinAbonnement FROM document ";
        $requete .= "JOIN abonnement ON document.id = abonnement.idRevue ";
        $requete .= "JOIN commande ON commande.id = abonnement.id  ";
        $requete .= "WHERE abonnement.dateFinAbonnement BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 30 DAY) ";
        $requete .= "ORDER BY abonnement.dateFinAbonnement ASC";
        
        return $this->conn->queryBDD($requete);
    }
}