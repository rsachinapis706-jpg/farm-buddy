import 'package:flutter/material.dart';

import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/models/crop_health.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/models/farmer.dart';
import 'package:farm_buddy/models/market.dart';
import 'package:farm_buddy/models/market_insight.dart';
import 'package:farm_buddy/models/transport.dart';
import 'package:farm_buddy/models/user_profile.dart';

/// Demo content for the Smart India Hackathon build.
///
/// Everything here is realistic for Coimbatore district, Tamil Nadu, and is
/// clearly labelled in the UI with a "Demo data" chip. Swap this file for a
/// real API client and no screen has to change.
abstract final class MockData {
  static DateTime _minutesAgo(int minutes) =>
      DateTime.now().subtract(Duration(minutes: minutes));

  // ------------------------------------------------------------- crops
  static const List<Crop> crops = <Crop>[
    Crop(
      id: 'tomato',
      name: 'Tomato',
      emoji: '🍅',
      seasonHint: 'Peak arrivals Jan–Mar',
      indicativePricePerKg: 28,
    ),
    Crop(
      id: 'onion',
      name: 'Onion',
      emoji: '🧅',
      seasonHint: 'Stores well for 3–4 weeks',
      indicativePricePerKg: 24,
    ),
    Crop(
      id: 'potato',
      name: 'Potato',
      emoji: '🥔',
      seasonHint: 'Steady demand all year',
      indicativePricePerKg: 22,
    ),
    Crop(
      id: 'banana',
      name: 'Banana',
      emoji: '🍌',
      seasonHint: 'Sell within 2 days of cutting',
      indicativePricePerKg: 32,
    ),
    Crop(
      id: 'paddy',
      name: 'Paddy',
      emoji: '🌾',
      seasonHint: 'Samba harvest Jan–Feb',
      indicativePricePerKg: 21,
    ),
    Crop(
      id: 'coconut',
      name: 'Coconut',
      emoji: '🥥',
      seasonHint: 'Year round, best Apr–Jun',
      indicativePricePerKg: 18,
    ),
  ];

  static Crop cropById(String id) =>
      crops.firstWhere((Crop c) => c.id == id, orElse: () => crops.first);

  // ----------------------------------------------------------- markets
  static final List<Market> markets = <Market>[
    Market(
      id: 'uzhavar-singanallur',
      name: 'Uzhavar Sandhai, Singanallur',
      type: MarketType.uzhavarSandhai,
      area: 'Singanallur, Coimbatore',
      pricePerKg: 32,
      yesterdayPricePerKg: 29.5,
      distanceKm: 12,
      demand: DemandLevel.high,
      requiredQuantityKg: 1200,
      todaysArrivalsKg: 4200,
      travelCostEstimate: 850,
      openHours: '6:00 AM – 1:00 PM',
      priceHistory: <double>[26, 27, 26.5, 28, 29, 29.5, 32],
      reasonKeys: <String>[
        'reason.goodPrice',
        'reason.highDemand',
        'reason.nearby',
        'reason.acceptsQuantity',
      ],
      mapX: 0.66,
      mapY: 0.34,
      latitude: 11.0009,
      longitude: 77.029,
      updatedAt: _minutesAgo(10),
    ),
    Market(
      id: 'srv-annur',
      name: 'SRV Traders, Annur',
      type: MarketType.privateBuyer,
      area: 'Annur, Coimbatore',
      pricePerKg: 30,
      yesterdayPricePerKg: 30,
      distanceKm: 5,
      demand: DemandLevel.medium,
      requiredQuantityKg: 800,
      todaysArrivalsKg: 1600,
      travelCostEstimate: 420,
      openHours: '7:00 AM – 6:00 PM',
      priceHistory: <double>[28, 28.5, 29, 29, 30, 30, 30],
      reasonKeys: <String>[
        'reason.nearby',
        'reason.lowTravelCost',
        'reason.trustedBuyer',
        'reason.acceptsQuantity',
      ],
      mapX: 0.38,
      mapY: 0.24,
      latitude: 11.2333,
      longitude: 77.1,
      updatedAt: _minutesAgo(12),
    ),
    Market(
      id: 'mettupalayam-regulated',
      name: 'Mettupalayam Regulated Market',
      type: MarketType.regulatedMandi,
      area: 'Mettupalayam, Coimbatore',
      pricePerKg: 29,
      yesterdayPricePerKg: 29.5,
      distanceKm: 8,
      demand: DemandLevel.medium,
      requiredQuantityKg: 2500,
      todaysArrivalsKg: 6800,
      travelCostEstimate: 610,
      openHours: '5:30 AM – 12:00 PM',
      priceHistory: <double>[30, 30.5, 30, 29.5, 29.5, 29.5, 29],
      reasonKeys: <String>[
        'reason.bigCapacity',
        'reason.nearby',
        'reason.openNow',
      ],
      mapX: 0.26,
      mapY: 0.62,
      latitude: 11.299,
      longitude: 76.937,
      updatedAt: _minutesAgo(18),
    ),
    Market(
      id: 'pollachi-wholesale',
      name: 'Pollachi Wholesale Mandi',
      type: MarketType.regulatedMandi,
      area: 'Pollachi, Coimbatore',
      pricePerKg: 27.5,
      yesterdayPricePerKg: 26,
      distanceKm: 41,
      demand: DemandLevel.high,
      requiredQuantityKg: 5000,
      todaysArrivalsKg: 12400,
      travelCostEstimate: 2100,
      openHours: '4:00 AM – 11:00 AM',
      priceHistory: <double>[24, 24.5, 25, 25.5, 26, 26, 27.5],
      reasonKeys: <String>[
        'reason.highDemand',
        'reason.bigCapacity',
      ],
      mapX: 0.78,
      mapY: 0.82,
      latitude: 10.6589,
      longitude: 77.0089,
      updatedAt: _minutesAgo(24),
    ),
    Market(
      id: 'kongu-fpo-sulur',
      name: 'Kongu FPO Collection Centre',
      type: MarketType.fpo,
      area: 'Sulur, Coimbatore',
      pricePerKg: 26,
      yesterdayPricePerKg: 26.5,
      distanceKm: 9,
      demand: DemandLevel.low,
      requiredQuantityKg: 600,
      todaysArrivalsKg: 900,
      travelCostEstimate: 520,
      openHours: '8:00 AM – 4:00 PM',
      priceHistory: <double>[27, 27, 26.5, 26.5, 26.5, 26.5, 26],
      reasonKeys: <String>[
        'reason.nearby',
        'reason.lowArrivals',
      ],
      mapX: 0.52,
      mapY: 0.70,
      latitude: 11.025,
      longitude: 77.126,
      updatedAt: _minutesAgo(31),
    ),
  ];

  static Market marketById(String id) => markets.firstWhere(
        (Market m) => m.id == id,
        orElse: () => markets.first,
      );

  // ---------------------------------------------------------- insight
  static MarketInsight get todayInsight => MarketInsight(
        cropName: 'Tomato',
        cropEmoji: '🍅',
        pricePerKg: 28,
        changePercent: 8,
        distanceKm: 12,
        demand: DemandLevel.high,
        marketId: 'uzhavar-singanallur',
        marketName: 'Uzhavar Sandhai, Singanallur',
        priceHistory: const <double>[24, 25, 25.5, 26, 26, 26, 28],
        updatedAt: _minutesAgo(10),
      );

  // ---------------------------------------------------------- farmers
  static const List<NearbyFarmer> nearbyFarmers = <NearbyFarmer>[
    NearbyFarmer(
      id: 'f1',
      name: 'Murugan S.',
      village: 'Sulur',
      distanceKm: 2.4,
      cropName: 'Tomato',
      cropEmoji: '🍅',
      quantityKg: 300,
      avatarSeed: 1,
      latitude: 11.029,
      longitude: 77.119,
      tagKeys: <String>['tag.sameCrop', 'tag.collective'],
      rating: 4.7,
    ),
    NearbyFarmer(
      id: 'f2',
      name: 'Lakshmi R.',
      village: 'Annur',
      distanceKm: 3.1,
      cropName: 'Tomato',
      cropEmoji: '🍅',
      quantityKg: 450,
      avatarSeed: 2,
      latitude: 11.23,
      longitude: 77.096,
      tagKeys: <String>['tag.sameCrop', 'tag.seeds'],
      rating: 4.9,
    ),
    NearbyFarmer(
      id: 'f3',
      name: 'Karthik M.',
      village: 'Kinathukadavu',
      distanceKm: 4.8,
      cropName: 'Tomato',
      cropEmoji: '🍅',
      quantityKg: 600,
      avatarSeed: 3,
      latitude: 10.76,
      longitude: 77.01,
      tagKeys: <String>['tag.sameCrop', 'tag.collective', 'tag.equipment'],
      rating: 4.5,
    ),
    NearbyFarmer(
      id: 'f4',
      name: 'Selvi P.',
      village: 'Thondamuthur',
      distanceKm: 6.2,
      cropName: 'Onion',
      cropEmoji: '🧅',
      quantityKg: 800,
      avatarSeed: 4,
      latitude: 10.98,
      longitude: 76.82,
      tagKeys: <String>['tag.rotation', 'tag.seeds'],
      rating: 4.6,
    ),
    NearbyFarmer(
      id: 'f5',
      name: 'Ramasamy K.',
      village: 'Pollachi Road',
      distanceKm: 7.5,
      cropName: 'Banana',
      cropEmoji: '🍌',
      quantityKg: 1200,
      avatarSeed: 5,
      latitude: 10.85,
      longitude: 76.98,
      tagKeys: <String>['tag.equipment', 'tag.collective'],
      rating: 4.4,
    ),
    NearbyFarmer(
      id: 'f6',
      name: 'Anitha D.',
      village: 'Sultanpet',
      distanceKm: 9.0,
      cropName: 'Paddy',
      cropEmoji: '🌾',
      quantityKg: 2000,
      avatarSeed: 6,
      latitude: 10.91,
      longitude: 77.04,
      tagKeys: <String>['tag.rotation'],
      rating: 4.8,
    ),
  ];

  static const GroupSaleOpportunity groupSale = GroupSaleOpportunity(
    cropName: 'Tomato',
    cropEmoji: '🍅',
    farmerCount: 3,
    totalQuantityKg: 1850,
    betterPricePerKg: 35,
    soloPricePerKg: 32,
    members: <NearbyFarmer>[
      NearbyFarmer(
        id: 'f1',
        name: 'Murugan S.',
        village: 'Sulur',
        distanceKm: 2.4,
        cropName: 'Tomato',
        cropEmoji: '🍅',
        quantityKg: 300,
        avatarSeed: 1,
        latitude: 11.029,
        longitude: 77.119,
        tagKeys: <String>['tag.sameCrop'],
        rating: 4.7,
      ),
      NearbyFarmer(
        id: 'f2',
        name: 'Lakshmi R.',
        village: 'Annur',
        distanceKm: 3.1,
        cropName: 'Tomato',
        cropEmoji: '🍅',
        quantityKg: 450,
        avatarSeed: 2,
        latitude: 11.23,
        longitude: 77.096,
        tagKeys: <String>['tag.sameCrop'],
        rating: 4.9,
      ),
      NearbyFarmer(
        id: 'f3',
        name: 'Karthik M.',
        village: 'Kinathukadavu',
        distanceKm: 4.8,
        cropName: 'Tomato',
        cropEmoji: '🍅',
        quantityKg: 600,
        avatarSeed: 3,
        latitude: 10.76,
        longitude: 77.01,
        tagKeys: <String>['tag.sameCrop'],
        rating: 4.5,
      ),
    ],
  );

  // -------------------------------------------------------- transport
  static const TransportRoute transportRoute = TransportRoute(
    pickupName: 'Your Farm',
    pickupSub: 'Sulur, Coimbatore',
    destinationName: 'Uzhavar Sandhai, Singanallur',
    destinationSub: 'Singanallur, Coimbatore',
    distanceKm: 12,
    durationMinutes: 35,
    estimatedCost: 2200,
  );

  static const List<TransportOption> transportOptions = <TransportOption>[
    TransportOption(
      id: 't1',
      providerName: 'Tata Ace',
      driverName: 'Selvam R.',
      type: VehicleType.miniTruck,
      capacityKg: 1500,
      price: 2200,
      etaMinutes: 25,
      isAvailable: true,
      rating: 4.6,
    ),
    TransportOption(
      id: 't2',
      providerName: 'Mahindra Jeeto',
      driverName: 'Bhaskar P.',
      type: VehicleType.tempo,
      capacityKg: 900,
      price: 1450,
      etaMinutes: 18,
      isAvailable: true,
      rating: 4.3,
    ),
    TransportOption(
      id: 't3',
      providerName: 'Bolero Pickup',
      driverName: 'Ganesh V.',
      type: VehicleType.pickup,
      capacityKg: 1200,
      price: 1850,
      etaMinutes: 30,
      isAvailable: false,
      rating: 4.5,
    ),
  ];

  static const TransportOption sharedTransport = TransportOption(
    id: 't-shared',
    providerName: 'Eicher 14ft',
    driverName: 'Arumugam T.',
    type: VehicleType.sharedTruck,
    capacityKg: 4000,
    price: 1500,
    etaMinutes: 40,
    isAvailable: true,
    rating: 4.7,
    isShared: true,
    savingAmount: 700,
    sharingFarmerCount: 2,
  );

  // ---------------------------------------------------------- profile
  static const FarmerProfile profile = FarmerProfile(
    name: 'Murugan Sakthivel',
    village: 'Sulur',
    district: 'Coimbatore, Tamil Nadu',
    phone: '+91 98••• ••210',
    crops: <String>['Tomato', 'Onion', 'Banana'],
    totalListings: 14,
    totalTransactions: 9,
    totalEarnings: 186400,
    memberSince: 'Mar 2024',
    rating: 4.8,
  );

  // ----------------------------------------------------- crop health
  static CropHealthResult healthyResult({String? imagePath}) => CropHealthResult(
        cropName: 'Tomato',
        cropEmoji: '🍅',
        status: HealthStatus.healthy,
        confidence: 0.92,
        summaryKey: 'health.summary.healthy',
        imagePath: imagePath,
        analyzedAt: DateTime.now(),
        advice: const <HealthAdvice>[
          HealthAdvice(
            titleKey: 'health.advice.harvest.title',
            bodyKey: 'health.advice.harvest.body',
            icon: Icons.agriculture_rounded,
          ),
          HealthAdvice(
            titleKey: 'health.advice.spacing.title',
            bodyKey: 'health.advice.spacing.body',
            icon: Icons.air_rounded,
          ),
          HealthAdvice(
            titleKey: 'health.advice.sort.title',
            bodyKey: 'health.advice.sort.body',
            icon: Icons.inventory_2_outlined,
          ),
        ],
      );

  static CropHealthResult diseasedResult({String? imagePath}) => CropHealthResult(
        cropName: 'Tomato',
        cropEmoji: '🍅',
        status: HealthStatus.possibleDisease,
        confidence: 0.87,
        summaryKey: 'health.summary.disease',
        imagePath: imagePath,
        analyzedAt: DateTime.now(),
        advice: const <HealthAdvice>[
          HealthAdvice(
            titleKey: 'health.advice.leaves.title',
            bodyKey: 'health.advice.leaves.body',
            icon: Icons.search_rounded,
          ),
          HealthAdvice(
            titleKey: 'health.advice.water.title',
            bodyKey: 'health.advice.water.body',
            icon: Icons.water_drop_outlined,
          ),
          HealthAdvice(
            titleKey: 'health.advice.expert.title',
            bodyKey: 'health.advice.expert.body',
            icon: Icons.support_agent_rounded,
          ),
        ],
      );
}
