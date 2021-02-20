# Coach@Home
![Logo](https://github.com/elpanas/CoachAtHomeApp/blob/master/images/logo.png)
## Sviluppatore

**Nome:** Luca 

**Cognome:** Panariello 

**Matricola:** 309055

## Descrizione
Il progetto consiste in un'applicazione per smartphone che permette di cercare istruttori fitness/fisioterapisti per allenamenti a domicilio.

## Struttura e scelte implementative
L'applicazione è attualmente costituita da 3 componenti:
- **Client:**  app mobile implementata in Dart (Flutter)
- **Server:** un web service remoto implementato in Node.js
- **Archiviazione remota** database MongoDB Atlas
- **Archiviazione locale** flutter_secure_storage + database Sembast

#### Il Client
E' stato creato utilizzando il framework crossplatform Flutter, in modo da rendere l'app compatibile per Android e iOS, oltre che veloce ed efficiente.

#### Il Web Service
Il WS è stato implementato in linguaggio Node.js, utilizzando un approccio prevalentemente procedurale con l'aggiunta di alcune classi che forniscono funzioni extra.
Il fornitore dello spazio web è Heroku.

#### Il Database
E' stato scelto un database NoSQL, in particolare MongoDB fornito dall'azienda omonima. Nel database vengono memorizzate le informazioni sugli istruttori, sia quello remoto che locale. La differenza è che in quello locale sono memorizzate solo alcune info per richiamare poi quelle remote al bisogno.

Ogni documento del db remoto segue il seguente schema per la validazione:

**Coach**

| id | name | username | password | location | city | phone | instant_msg | mail | web | facebook | instagram | linkedin | bio |
| -- | ---- | -------- | -------- | -------- | ---- | ----- | ---------- | ---- | --- | -------- | --------- | -------- | --- |
| ObjectID | String | String | String | object | String | String | boolean | String | String | String | String | String | String |


## Funzionalità
- #### Ricerca per posizione
L'app invia la propria posizione in modo semi-silente al webservice e riceve la lista degli istruttori in un raggio di 20Km
- #### Lista Preferiti
Dal menu laterale (Drawer) l'utente accede ad una lista preferiti o al proprio profilo se è registrato.

## Casi d'uso
- Utente non registrato: può accedere alla ricerca, ai preferiti (visualizzazione/modifica/cancellazione) e ai profili (visualizzazione).
- Utente registrato: può accedere alle stesse funzioni dell'utente non registrato, più la possibilità di effettuare il login, logout e modificare il proprio profilo.

## App Mobile - Esperienza utente (UX)
Premendo il tasto Cerca viene inviata l'attuale posizione in base alla quale il web service provvederà a richiedere i dati al DB e ad inviarli in formato JSON al client, che li visualizzerà.

![lista](https://github.com/elpanas/CoachAtHomeApp/blob/master/images/list.png)

Cliccando su ogni nome l'app porterà l'utente ad una nuova pagina Profilo, dove sarà possibile avere maggiori informazioni e contatti.

![profilo](https://github.com/elpanas/CoachAtHomeApp/blob/master/images/profile.png)

Cliccando sui contatti e sulle icone dei relativi social (ove presenti), l'utente viene indirizzato automaticamente all'app corrispondente.
Inoltre è possibile aggiungere l'allenatore ad una lista preferiti, cliccando sul pulsante con il cuore. I dati essenziali verranno inseriti un un database locale, sempre NoSQL, chiamato Sembast che corrisponde ad un semplice file memorizzato nello smartphone.

![preferiti](https://github.com/elpanas/CoachAtHomeApp/blob/master/images/fav.png)

Se a visualizzare la pagina profilo è lo stesso allenatore, al posto del cuore appare un'icona con la matita. Cliccandola si viene reindirizzati alla pagina di modifica, in cui alcuni campi potrebbero essere già riempiti con i dati presenti nel database remoto.

![modifica](https://github.com/elpanas/CoachAtHomeApp/blob/master/images/mod.png)

### Tecnologia

<pre>
http.post(
      url + 'coach/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic>{
        'name': first + ' ' + full,
        'username': base64.encode(utf8.encode(name)),
        'password': base64.encode(utf8.encode(psw)),
        'location': {
          'type': "Point",
          'coordinates': [position.latitude, position.longitude]
        },
        'city': cityController.text
      }),
    );
</pre>

Effettua il login:

<pre>
Future makeLogin(String name, String psw) async {
    var pin = base64.encode(utf8.encode(name + ':' + psw));
    return http.get(
      url + 'coach/login',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Basic ' + pin
      },
    );
  }
</pre>

Invia i dati in formato JSON con una richiesta PUT:

<pre>
http.put(
      url + 'coach',
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Basic ' + this.pin
      },
      body: jsonEncode(<String, dynamic>{
        'id': profile.id.toString(),
        'phone': cellController.text ?? '',
        'instant_msg': _checked,
        'mail': mailController.text ?? '',
        'web': webController.text ?? '',
        'facebook': fbController.text ?? '',
        'instagram': instaController.text ?? '',
        'linkedin': linkController.text ?? '',
        'bio': bioController.text ?? ''
      }),
    );
</pre>

Richiede la lista allenatori in base alla posizione
<pre>
http.get(url + 'coach' + '/latitude/' + latitude + '/longitude/' + longitude)
</pre>

### Pacchetti
*Geolocator:* restituisce informazioni riguardanti la posizione dell'utente. In particolare vengono utilizzate le coordinate latitudine e longitudine (Lista istruttori)

*Flutter Secure Storage:* memorizza i dati in aree di memoria criptate dello smartphone. In questo caso sono stati memorizzati username, password e l'id dell'utente se registrato.

*Flutter Phone Direct Caller:* permette di effettuare una chiamata il dialer dello smartphone (Profilo)

*URL Launcher:* apre il link con il browser dello smartphone (Profilo)

*Flutter E-mail sender:* apre l'app per le mail predefinita e crea un nuovo messaggio con l'email fornita (Profilo)

*Social Media Buttons:* permettono di aprire le rispettive app al click sulla relativa icona. (Profilo)

*Material Design Icons Flutter:* fornisce icone aggiuntive mancanti, ad esempio quelle dei social. (Profilo)

*Sembast:* database NoSQL locale. Vengono memorizzati/letti i preferiti (Profilo, Preferiti)

*Path Provider:* fornisce il percorso predefinito di alcune cartelle dello smartphone, ad esempio Documenti, Download. In questo caso è stato utilizzato per avere il percorso della cartella in cui memorizzare il file del db Sembast.

## Web Service
L'API basa il suo funzionamento sull'interscambio di dati tra client e server per mezzo di richieste HTTP così formate:

### HTTP Requests client/server
Le richieste HTTP tra il client e il web service sono di tipo POST, GET e PUT.

Sia quelle in input che output trasportano dati in formato JSON, preventivamente (de)codificati per mezzo dell'apposita funzione <code>jsonEncode/Decode()</code> fornita dal framework Node.js sul server e Flutter sul client.

I dati all'interno dei file JSON, sono costituiti da voci di menu, informazioni sulla posizione e password.

Si è scelto di utilizzare il linguaggio Node.js data la natura testuale delle informazioni scambiate.
Framework e Addons utilizzati:

- **Express:** semplifica la gestione degli endpoint e dei request/response
- **Mongoose:** semplifica le query al DB
- **Bcrypt:** crea l'hash delle password
- **Dotenv:** accede alle variabili d'ambiente

Endpoints e metodi:

<pre>
router.post('/', (req, res) => createCoach())
router.get('/latitude/:lat/longitude/:long', (req, res) => getCoaches())
router.get('/id/:id', (req, res) => getCoach())
router.get('/login', (req, res) => checkLogin())
router.put('/', (req, res) => updateCoach())
</pre>

### Query al DB remoto
Ogni query viene effettuata per mezzo del framework Mongoose utilizzando il metodo .lean() al termine delle pipeline, in modo da ottenere degli oggetti semplici e leggeri, da inviare poi tramite Node.js Express al client.

### Sicurezza
Le richieste HTTP avvengono tutte (POST, GET, PUT) con protocollo https.

E' utilizzata un'autenticazione base per evitare richieste put indesiderate all'API

La stringa di accesso al DB remoto è memorizzata in variabili d'ambiente impostate tramite l'interfaccia Heroku.

## Messa online del web service
Avviene automaticamente, in quanto il fornitore dello spazio web, Heroku, è collegato alla repository GitHub dell'app in questione. Ad ogni modifica, i file presenti sul branch indicato vengono caricati sui server Heroku.

### Info sul test

**Client**
* Modello: HTC One M9
* Sistema Operativo: Android 7.0 Nougat
* Framework: Flutter

**Server**
* Server Web: Apache 2
* Web Service: Node.js 14.15
* Database: MongoDB 4.4 Atlas, 512MB, RAM condivisa

## Conclusione
L'applicazione crea una piattaforma di comunicazione tra il cliente (l'atleta) e l'istruttore in modo da dare al primo la possibilità di allenarsi a casa e al secondo visibilità che invece non avrebbe, poichè non appare sulle mappe o sui vecchi elenchi telefonici.