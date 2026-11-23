# Aula 14 - Geolocalizacao e GPS

Projeto Flutter utilizando o pacote `geolocator` para captura de coordenadas e rastreamento contínuo.

## Funcionalidades
- Verificação do serviço de GPS
- Tratamento de permissões e erros
- Captura única de coordenadas (`getCurrentPosition`)
- Rastreamento contínuo (`getPositionStream`)

## Desafios Implementados
- **Básico:** Chip de precisão (Verde < 15m, Amarelo 15-50m, Vermelho > 50m).
- **Intermediário:** Cálculo de distância até a Fatec Matão usando `distanceBetween`.

## Capturas de Tela

**1. Coordenadas capturadas:**
![Coordenadas](screenshots/01-coordenadas.png)

**2. Rastreamento contínuo:**
![Rastreamento](screenshots/02-rastreamento.png)

**3. Tratamento de erro (permissão negada):**
![Erro](screenshots/03-gps-desativado.png)

## Como rodar
```bash
flutter pub get
flutter run